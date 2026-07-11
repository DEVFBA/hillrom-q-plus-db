USE DBQS
GO

SET NOCOUNT ON;
GO

BEGIN TRY
	BEGIN TRAN;

	IF OBJECT_ID('dbo.GSS_Cat_Item', 'U') IS NULL
		THROW 50001, 'Table dbo.GSS_Cat_Item does not exist.', 1;

	IF OBJECT_ID('dbo.GSS_Cat_Packages_Lines', 'U') IS NULL
		THROW 50002, 'Table dbo.GSS_Cat_Packages_Lines does not exist.', 1;

	IF COL_LENGTH('dbo.GSS_Cat_Packages_Lines', 'Id_Package_Line') IS NULL
		THROW 50003, 'Column dbo.GSS_Cat_Packages_Lines.Id_Package_Line does not exist.', 1;

	-- Ensure default parent value exists for FK and legacy/null data mapping.
	IF NOT EXISTS (
		SELECT 1
		FROM dbo.GSS_Cat_Packages_Lines
		WHERE Id_Package_Line = 'NA'
	)
	BEGIN
		INSERT INTO dbo.GSS_Cat_Packages_Lines (
			Id_Package_Line,
			Short_Desc,
			Long_Desc,
			Status,
			Modify_By,
			Modify_Date,
			Modify_IP
		)
		VALUES (
			'NA',
			'Not Apply',
			'Not Apply',
			1,
			'ANGUTIERRE',
			GETDATE(),
			'DB'
		);
	END;

	-- Rename Id_Item_Related to Id_Package_Line (only if rename is still pending).
	IF COL_LENGTH('dbo.GSS_Cat_Item', 'Id_Item_Related') IS NOT NULL
	   AND COL_LENGTH('dbo.GSS_Cat_Item', 'Id_Package_Line') IS NULL
	BEGIN
		EXEC sp_rename 'dbo.GSS_Cat_Item.Id_Item_Related', 'Id_Package_Line', 'COLUMN';
	END;

	IF COL_LENGTH('dbo.GSS_Cat_Item', 'Id_Package_Line') IS NULL
		THROW 50004, 'Column Id_Package_Line was not found in dbo.GSS_Cat_Item after rename check.', 1;

	DECLARE @sql NVARCHAR(MAX);

	-- Normalize legacy null/blank values to default NA.
	SET @sql = N'
		UPDATE dbo.GSS_Cat_Item
		SET Id_Package_Line = ''NA''
		WHERE Id_Package_Line IS NULL
		   OR LTRIM(RTRIM(Id_Package_Line)) = '''';';
	EXEC sp_executesql @sql;

	SET @sql = N'
		SELECT @hasTooLongOut = CASE WHEN EXISTS (
			SELECT 1
			FROM dbo.GSS_Cat_Item
			WHERE LEN(LTRIM(RTRIM(Id_Package_Line))) > 10
		) THEN 1 ELSE 0 END;';

	DECLARE @hasTooLong BIT = 0;
	EXEC sp_executesql @sql, N'@hasTooLongOut BIT OUTPUT', @hasTooLong OUTPUT;

	IF @hasTooLong = 1
		THROW 50005, 'Cannot change to VARCHAR(10): existing Id_Package_Line values longer than 10 characters were found.', 1;

	DECLARE @dropDefaultSql NVARCHAR(MAX) = N'';

	SELECT @dropDefaultSql =
		N'ALTER TABLE dbo.GSS_Cat_Item DROP CONSTRAINT [' + dc.name + N'];'
	FROM sys.default_constraints dc
	INNER JOIN sys.columns c
		ON c.object_id = dc.parent_object_id
	   AND c.column_id = dc.parent_column_id
	WHERE dc.parent_object_id = OBJECT_ID('dbo.GSS_Cat_Item')
	  AND c.name = 'Id_Package_Line';

	IF @dropDefaultSql <> N''
		EXEC sp_executesql @dropDefaultSql;

	SET @sql = N'ALTER TABLE dbo.GSS_Cat_Item ALTER COLUMN Id_Package_Line VARCHAR(10) NOT NULL;';
	EXEC sp_executesql @sql;

	IF NOT EXISTS (
		SELECT 1
		FROM sys.default_constraints
		WHERE parent_object_id = OBJECT_ID('dbo.GSS_Cat_Item')
		  AND name = 'DF_GSS_Cat_Item_Id_Package_Line'
	)
	BEGIN
		SET @sql = N'ALTER TABLE dbo.GSS_Cat_Item ADD CONSTRAINT DF_GSS_Cat_Item_Id_Package_Line DEFAULT (''NA'') FOR Id_Package_Line;';
		EXEC sp_executesql @sql;
	END;

	DECLARE @fkName SYSNAME;
	DECLARE @dropFkSql NVARCHAR(MAX);

	DECLARE @fksToDrop TABLE (
		fk_name SYSNAME NOT NULL PRIMARY KEY
	);

	INSERT INTO @fksToDrop (fk_name)
	SELECT DISTINCT fk.name
	FROM sys.foreign_keys fk
	INNER JOIN sys.foreign_key_columns fkc
		ON fkc.constraint_object_id = fk.object_id
	INNER JOIN sys.columns c
		ON c.object_id = fkc.parent_object_id
	   AND c.column_id = fkc.parent_column_id
	WHERE fk.parent_object_id = OBJECT_ID('dbo.GSS_Cat_Item')
	  AND c.name = 'Id_Package_Line';

	WHILE EXISTS (SELECT 1 FROM @fksToDrop)
	BEGIN
		SELECT TOP (1) @fkName = fk_name
		FROM @fksToDrop
		ORDER BY fk_name;

		SET @dropFkSql = N'ALTER TABLE dbo.GSS_Cat_Item DROP CONSTRAINT [' + @fkName + N'];';
		EXEC sp_executesql @dropFkSql;

		DELETE FROM @fksToDrop
		WHERE fk_name = @fkName;
	END;

	SET @sql = N'
		ALTER TABLE dbo.GSS_Cat_Item WITH CHECK
		ADD CONSTRAINT FK_GSSCatItem_GSSCatPackagesLines
			FOREIGN KEY (Id_Package_Line)
			REFERENCES dbo.GSS_Cat_Packages_Lines (Id_Package_Line);';
	EXEC sp_executesql @sql;

	SET @sql = N'ALTER TABLE dbo.GSS_Cat_Item CHECK CONSTRAINT FK_GSSCatItem_GSSCatPackagesLines;';
	EXEC sp_executesql @sql;

	COMMIT TRAN;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;

	THROW;
END CATCH;
GO
