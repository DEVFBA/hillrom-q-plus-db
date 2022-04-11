use DBQS
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spNotification_ValidateExecution 
/* ==================================================================================*/	
PRINT 'Crea Procedure: spNotification_ValidateExecution'

IF OBJECT_ID('[dbo].[spNotification_ValidateExecution]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spNotification_ValidateExecution
GO



/*====================================================================================================================================
Author		: Alejandro Zepeda
Descrption	: Validate the execution time of the Notifications
Creation	: 17-04-2021
Return		: Boolean
Ex.:		: 
			EXEC spNotification_ValidateExecution @piIdNotification = 5
			 Specific Frequency = W|Saturday|09:30-18:30  Server = Saturday | 17:50
======================================================================================================================================*/

CREATE PROCEDURE [dbo].spNotification_ValidateExecution 
@piIdNotification	Int
AS
SET LANGUAGE English


DECLARE	@vSpecificFrequency	VARCHAR(MAX)	= ISNULL((SELECT Specific_Frequency FROM Cat_Notifications WHERE Id_Notification = @piIdNotification),'')
DECLARE	@Item				VARCHAR(MAX)	= ''
DECLARE	@bValidSchedule		BIT				= 0 
DECLARE	@Contador			INT				= 0
DECLARE	@Periodicidad		VARCHAR(20)		= ''
DECLARE	@Dias				VARCHAR(MAX)	= ''
DECLARE	@Horas				VARCHAR(MAX)	= ''
DECLARE	@Dia				VARCHAR(10)     = ''
DECLARE	@Validacion			BIT				= 0


IF @vSpecificFrequency <> ''
BEGIN

		DECLARE propEjec CURSOR FOR
		SELECT Valor FROM fnSplit(@vSpecificFrequency,'|')

		OPEN propEjec

		FETCH NEXT FROM propEjec INTO @Item

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @Item

			IF @Contador = 0
				SET @Periodicidad = @Item
	
			IF @Contador = 1
			BEGIN
				IF @Periodicidad = 'D'
					SET @Horas = @Item
				ELSE
					SET @Dias = @Item
			END
		

			IF @Contador = 2
				SET @Horas = @Item
	
			SET @Contador = @Contador + 1 

		  FETCH NEXT FROM propEjec INTO @Item
		END 
		CLOSE propEjec;
		DEALLOCATE propEjec;


		BEGIN TRY
				IF @Contador <= 3
				 BEGIN
					IF @Periodicidad = 'D' OR @Periodicidad = 'S' OR @Periodicidad = 'W' OR @Periodicidad = 'M' OR @Periodicidad = 'F'
						BEGIN
							IF @Periodicidad = 'D'
								BEGIN 
									SET @Validacion = 1
									IF @Horas = ''
									BEGIN
										SET @bValidSchedule = 1
									END
									ELSE
										SET @bValidSchedule = (SELECT dbo.fnValidateSchedules(@Horas))
								END
							IF @Periodicidad = 'S' or  @Periodicidad = 'W'
								BEGIN 
									DECLARE TMPDIAS CURSOR FOR
									SELECT Valor FROM fnSplit(@Dias,',')
									OPEN TMPDIAS
									FETCH NEXT FROM TMPDIAS INTO @Dia
									WHILE @@FETCH_STATUS = '0'
									BEGIN
										PRINT @Dia
										IF @Dia = 'Lunes' OR @Dia = 'Mondey' OR @Dia = 'Martes' OR @Dia = 'Tuesday' OR @Dia = 'Miércoles' OR @Dia = 'Wednesday' OR @Dia = 'Jueves' OR @Dia = 'Thursday' OR @Dia = 'Viernes' OR @Dia = 'Friday' OR @Dia = 'Sábado' OR @Dia = 'Saturday' OR @Dia = 'Domingo' OR @Dia = 'Sunday'
										BEGIN
											SET @Validacion = 1
										END
										ELSE
										BEGIN
											SET @Validacion=0
											BREAK
										END
		
										IF @Dia = (select DATENAME(dw,GETDATE()))
										BEGIN
											SET @Validacion = 1
											SET @bValidSchedule = (SELECT dbo.fnValidateSchedules(@Horas))
										END
										FETCH NEXT FROM TMPDIAS INTO @Dia
									END
									CLOSE TMPDIAS;
									DEALLOCATE TMPDIAS;
								END
							IF @Periodicidad = 'M'
								BEGIN 
									DECLARE TMPDIAS CURSOR FOR
									SELECT Valor FROM fnSplit(@Dias,',')
									OPEN TMPDIAS
									FETCH NEXT FROM TMPDIAS INTO @Dia
									WHILE @@FETCH_STATUS = '0'
									BEGIN
										IF @Dia > 0 and @Dia < 32
											SET @Validacion = 1
										ELSE
											BEGIN
												SET @Validacion =0 
												BREAK
											END
										IF @Dia = (SELECT DATEPART(d,GETDATE()))
										BEGIN
											print @Dia
											SET @Validacion = 1
											SET @bValidSchedule = (SELECT dbo.fnValidateSchedules(@Horas))
										END
										FETCH NEXT FROM TMPDIAS INTO @Dia
									END
									CLOSE TMPDIAS;
									DEALLOCATE TMPDIAS;
								END
							IF @Periodicidad = 'F'
								BEGIN 
									DECLARE TMPDIAS CURSOR FOR
									SELECT Valor FROM fnSplit(@Dias,',')
									OPEN TMPDIAS
									FETCH NEXT FROM TMPDIAS INTO @Dia
									WHILE @@FETCH_STATUS = '0'
									BEGIN
										PRINT @Dia
										select Convert(DATETIME,@Dia,105)
										SET @Validacion = 1
										IF @Dia = Convert(VARCHAR(10),GETDATE(),105) OR @Dia = Convert(VARCHAR(10),GETDATE(),103)
										BEGIN
											SET @bValidSchedule = (SELECT dbo.fnValidateSchedules(@Horas))
										END
										FETCH NEXT FROM TMPDIAS INTO @Dia
									END
									CLOSE TMPDIAS;
									DEALLOCATE TMPDIAS;
								END

								IF @bValidSchedule = 1
									SELECT	Execution_Enabled	= @bValidSchedule, 
											Execution_Detail	= ' Specific Frequency = ' + @vSpecificFrequency + ' vs Server = ' +  DATENAME(dw,GETDATE()) + ' | '  +  CONVERT(CHAR(5), GETDATE(), 108)
								ELSE
									BEGIN
										IF @Validacion = 1
											SELECT	Execution_Enabled = @bValidSchedule, 
													Execution_Detail	= ' Out of Range Specific Frequency = ' + @vSpecificFrequency + ' vs Server = ' +  DATENAME(dw,GETDATE()) + ' | '  +  CONVERT(CHAR(5), GETDATE(), 108)
										ELSE
											SELECT	Execution_Enabled = @bValidSchedule, 
													Execution_Detail	= ' Error Specific Frequency = ' + @vSpecificFrequency + ' vs Server = ' +  DATENAME(dw,GETDATE()) + ' | '  +  CONVERT(CHAR(5), GETDATE(), 108)
									END
								END
						ELSE
							 BEGIN
								SELECT	Execution_Enabled = @bValidSchedule, 
										Execution_Detail	= 'Format Error Specific Frequency = ' + @vSpecificFrequency + ' vs Server = ' +  DATENAME(dw,GETDATE()) + ' | '  +  CONVERT(CHAR(5), GETDATE(), 108)
							 END
						END
				 ELSE
					 BEGIN
						SELECT	Execution_Enabled = @bValidSchedule, 
								Execution_Detail = 'Format Error Specific Frequency = ' + @vSpecificFrequency + ' vs Server = ' +  DATENAME(dw,GETDATE()) + ' | '  +  CONVERT(CHAR(5), GETDATE(), 108)
					END
		END TRY
		BEGIN CATCH
				IF (SELECT CURSOR_STATUS('global','TMPDIAS') )= 1 OR (SELECT CURSOR_STATUS('global','TMPDIAS') )= -1
				BEGIN	
					CLOSE TMPDIAS;
					DEALLOCATE TMPDIAS;
				END
				IF (SELECT CURSOR_STATUS('global','TMPHRS') )= 1 OR (SELECT CURSOR_STATUS('global','TMPHRS') )= -1
				BEGIN
					CLOSE TMPHRS;
					DEALLOCATE TMPHRS;
				END
		
				DECLARE @pError		Varchar(Max)
				SET @pError		= dbo.fnGetTransacErrorBD()
		
				SELECT	Execution_Enabled = @bValidSchedule, 
						Execution_Detail			= 'Execution BD Error :'+ @pError
	
		END CATCH	
END
ELSE
	BEGIN
		SET @bValidSchedule = 1
		SELECT	Execution_Enabled	= @bValidSchedule, 
				Execution_Detail			= 'Notification without frequency of execution'
	END

