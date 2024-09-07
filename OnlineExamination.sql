CREATE DATABASE ONLINEEXAMINATION
USE ONLINEEXAMINATION

CREATE SCHEMA Foundation

CREATE TABLE Foundation.Users (
	Id INT  PRIMARY KEY IDENTITY(1,1),
	NAME VARCHAR(800),
	DOB Date,
	Email VARCHAR(800),
)

CREATE TABLE Foundation.Admins (
	Id INT PRIMARY KEY IDENTITY(1,1),
	NAME VARCHAR(800),
	Email VARCHAR(800),
	AdminPassword Varchar(10),
)

CREATE TABLE Foundation.Quizzs (
	Id INT PRIMARY KEY IDENTITY(1,1),
	Title VARCHAR(800),
	Descriptions VARCHAR(800),
	AdminId INT FOREIGN KEY REFERENCES Foundation.Admins(ID),
	StartTime INT,
	EndTime INT,
)



CREATE TABLE Foundation.Questions (
	Id INT PRIMARY KEY IDENTITY(1,1),
	QuestionText VARCHAR(800),
	QuizId INT FOREIGN KEY REFERENCES Foundation.Quizzs(ID),
	QuestionType VARCHAR(200),
)

CREATE TABLE Foundation.Answers (
	Id INT PRIMARY KEY IDENTITY(1,1),
	AnswerText VARCHAR(500),
	IsCorrect BIT,
	QuestionId INT FOREIGN KEY REFERENCES Foundation.Questions(Id),
)

CREATE TABLE Foundation.UserQuizs (
	Id INT PRIMARY KEY IDENTITY(1,1),
	UserId INT FOREIGN KEY REFERENCES Foundation.Users(Id),
	QuizId INT FOREIGN KEY REFERENCES Foundation.Quizzs(Id),
	Score INT,
)

CREATE TABLE Foundation.UserAnswers (
	Id INT PRIMARY KEY IDENTITY(1,1),
	UserId INT FOREIGN KEY REFERENCES Foundation.Users(Id),
	QuestionId INT FOREIGN KEY REFERENCES Foundation.Questions(Id),
	AnswerId INT FOREIGN KEY REFERENCES Foundation.Answers(Id),
)	

SELECT Foundation.Questions.QuestionText, Foundation.Answers.AnswerText
FROM Foundation.Questions
INNER JOIN Foundation.Answers on Foundation.Questions.Id = Foundation.Answers.QuestionId and Foundation.Answers.IsCorrect = 1

--Inserting into Users
CREATE PROCEDURE spInsertUserQuizAnswers
@UserId INT,
@QuestionId INT,
@AnswerIds VARCHAR(MAX)
AS
BEGIN
	INSERT INTO Foundation.UserAnswers SELECT @UserId [UserId], @QuestionId [QuestionId], [value] [AnswerIds] FROM string_split(@AnswerIds,',');
END

EXEC spInsertUserQuizAnswers 1,1,'1,2'
SELECT * FROM Foundation.UserAnswers
--Deleting User

CREATE PROCEDURE spDeleteUser
@UserId Int 
AS
BEGIN
	DELETE FROM Foundation.UserAnswers WHERE UserId = @UserId
	DELETE FROM Foundation.UserQuizs WHERE UserId = @UserId
	DELETE FROM Foundation.Users WHERE Id = @UserId
END;

--Deleting admin

CREATE PROCEDURE spDeleteAdmin
@AdminId INT
AS
BEGIN

	DECLARE @Id INT;
	SELECT @Id = Id FROM Foundation.Quizzs WHERE AdminId = @AdminId;
	IF @Id IS NOT NULL
	EXEC spDeleteQuiz @QuizId = @Id;

	DELETE FROM Foundation.Admins WHERE Id = @AdminId
END;

--Deleting Quiz

CREATE PROCEDURE spDeleteQuiz
@QuizId INT
AS
BEGIN
	DELETE FROM Foundation.UserQuizs WHERE QuizId = @QuizId

	DECLARE @Id INT;
	SELECT @Id = Id FROM Foundation.Questions WHERE QuizId = @QuizId
	IF @Id IS NOT NULL
	BEGIN
		EXEC spDeleteQuestion @QuestionId = @Id
	END

	DELETE FROM Foundation.Quizzs WHERE Id = @QuizId
END;

--Deleting question

CREATE PROCEDURE spDeleteQuestion
@QuestionId INT
AS
BEGIN

	DECLARE @Id INT;
	SELECT @Id = Id FROM Foundation.Answers WHERE QuestionId = @QuestionId;
	IF @Id IS NOT NULL
	BEGIN
		EXEC spDeleteAnswer @AnswerId = @Id;
	END

	DELETE FROM Foundation.Questions WHERE Id = @QuestionId;
END;

--Deleting Answer

CREATE PROCEDURE spDeleteAnswer
@AnswerId INT
AS
BEGIN 
	DELETE FROM Foundation.UserAnswers WHERE AnswerId = @AnswerId
	DELETE FROM Foundation.Answers WHERE Id = @AnswerId
END;


SELECT * FROM Foundation.Users
SELECT * FROM Foundation.Admins
SELECT * FROM Foundation.Quizzs
SELECT * FROM Foundation.Answers
SELECT * FROM Foundation.Questions

SELECT Id from Foundation.Users Where Email = 'pathanriyazkhan136@gmail.com' and Password = '12345';