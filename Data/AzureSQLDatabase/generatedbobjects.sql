/****** Object:  Table [dbo].[Tweets]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tweets](
	[ID] [uniqueidentifier] NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
	[Sentiment] [float] NOT NULL,
	[TweetLanguageCode] [nvarchar](50) NULL,
	[TwitterID] [nvarchar](50) NOT NULL,
	[CreatedAt] [nvarchar](50) NOT NULL,
	[RetweetCount] [int] NOT NULL,
	[TweetedBy] [nvarchar](max) NOT NULL,
	[TwitterUserID] [nvarchar](50) NULL,
	[Location] [nvarchar](max) NULL,
	[BingLocation] [nvarchar](max) NULL,
	[OriginalTwitterUser] [nvarchar](max) NULL,
	[OriginalTweetID] [nvarchar](50) NULL,
	[RunID] [uniqueidentifier] NULL,
	[IsSentimentCalculated] [bit] NULL,
	[InvalidSentiment] [bit] NULL,
	[InvalidSentimentReason] [nvarchar](max) NULL,
	[ArePhrasesExtracted] [bit] NULL,
	[DateofTweet] [datetime] NULL,
 CONSTRAINT [PK_Tweets] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[viewTweets]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewTweets]
AS
SELECT        ID, Body, Sentiment, TweetLanguageCode, TwitterID, RetweetCount, TweetedBy, TwitterUserID, Location, BingLocation, DateofTweet AS DateCreated, OriginalTwitterUser, OriginalTweetID, RunID, IsSentimentCalculated, 
                         InvalidSentiment, InvalidSentimentReason
FROM            dbo.Tweets
WHERE        (Location <> '') AND (InvalidSentiment = 0 OR
                         InvalidSentiment IS NULL) AND (IsSentimentCalculated = 1)
GO
/****** Object:  Table [dbo].[LookupBadPhrases]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LookupBadPhrases](
	[Phrase] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_LookupBadPhrases] PRIMARY KEY CLUSTERED 
(
	[Phrase] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Phrases]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Phrases](
	[ID] [uniqueidentifier] NOT NULL,
	[Phrase] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Phrases] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_Phrases] UNIQUE NONCLUSTERED 
(
	[Phrase] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TweetPhrases]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TweetPhrases](
	[ID] [uniqueidentifier] NOT NULL,
	[PhraseID] [uniqueidentifier] NOT NULL,
	[TweetID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_TweetPhrases] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[viewPhrases]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewPhrases]
AS
SELECT        p.Phrase, tp.TweetID, tp.PhraseID
FROM            dbo.TweetPhrases AS tp INNER JOIN
                         Phrases AS p ON p.ID = tp.PhraseID LEFT OUTER JOIN
                         dbo.LookupBadPhrases AS l ON l.Phrase = p.Phrase
WHERE        (l.Phrase IS NULL)
GO
/****** Object:  View [dbo].[viewGetLatestTweet]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewGetLatestTweet]
AS
SELECT        TOP (1) TwitterID, DateCreated
FROM            dbo.viewTweets
ORDER BY DateCreated DESC
GO
/****** Object:  Table [dbo].[TweetLocations]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TweetLocations](
	[TweetLocationID] [uniqueidentifier] NOT NULL,
	[TweetLocation] [nvarchar](200) NOT NULL,
	[BingLocationCountry] [nvarchar](200) NULL,
	[BingJSON] [nvarchar](max) NULL,
	[BingLocation] [nvarchar](max) NULL,
	[BingPostCode] [nvarchar](max) NULL,
	[IsUpdated] [bit] NULL,
 CONSTRAINT [PK_TweetLocations] PRIMARY KEY CLUSTERED 
(
	[TweetLocationID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [IX_TweetLocations] UNIQUE NONCLUSTERED 
(
	[TweetLocation] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[viewLocations]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewLocations]
AS
SELECT        TweetLocationID, TweetLocation, BingLocationCountry, BingLocation, BingPostCode, IsUpdated, BingJSON
FROM            dbo.TweetLocations
GO
/****** Object:  View [dbo].[viewNoBingLocations]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewNoBingLocations]
AS
SELECT        TweetLocationID, TweetLocation, BingLocationCountry, BingJSON, BingLocation, BingPostCode, IsUpdated
FROM            dbo.TweetLocations
WHERE        (IsUpdated = 0) OR
                         (IsUpdated IS NULL)
GO
/****** Object:  View [dbo].[viewTweetsWithNoSentiment]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[viewTweetsWithNoSentiment]
AS
SELECT        TOP (1000) ID, Body, Sentiment, TweetLanguageCode, TwitterID, CreatedAt, RetweetCount, TweetedBy, TwitterUserID, Location, BingLocation, OriginalTwitterUser, OriginalTweetID, RunID, IsSentimentCalculated, 
                         InvalidSentiment, InvalidSentimentReason
FROM            dbo.Tweets
WHERE        (IsSentimentCalculated IS NULL) OR
                         (IsSentimentCalculated = 0)
GO
/****** Object:  View [dbo].[viewTweetsWithNoPhrases]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewTweetsWithNoPhrases]
AS
SELECT        TwitterID, ArePhrasesExtracted, Body, TweetLanguageCode, RunID, ID
FROM            dbo.Tweets
WHERE        (ArePhrasesExtracted = 0) OR
                         (ArePhrasesExtracted IS NULL)
GO
/****** Object:  View [dbo].[viewTopPhrases]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewTopPhrases]
AS
SELECT        COUNT(tp.TweetID) AS Count, p.Phrase, p.ID AS PhraseID
FROM            dbo.TweetPhrases AS tp INNER JOIN
                         Phrases AS p ON p.ID = tp.PhraseID
GROUP BY p.Phrase, p.ID
GO
/****** Object:  Table [dbo].[Runs]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Runs](
	[ID] [uniqueidentifier] NOT NULL,
	[DateStarted] [datetime] NOT NULL,
	[NumberofTweets] [int] NOT NULL,
	[NumberofUniqueTweets] [int] NOT NULL,
	[DateFinished] [datetime] NOT NULL,
	[LastTwitterID] [nvarchar](50) NULL,
	[IsSuccessful] [bit] NULL,
	[Errors] [nvarchar](max) NULL,
 CONSTRAINT [PK_Runs] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_LookupBadPhrases]    Script Date: 31/03/2020 08:00:06 ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_LookupBadPhrases] ON [dbo].[LookupBadPhrases]
(
	[Phrase]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
/****** Object:  Index [IX_TweetPhrases]    Script Date: 31/03/2020 08:00:06 ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_TweetPhrases] ON [dbo].[TweetPhrases]
(
	[PhraseID]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Phrases] ADD  CONSTRAINT [DF_Phrases_ID]  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [dbo].[TweetLocations] ADD  CONSTRAINT [DF_TweetLocations_TweetLocationID]  DEFAULT (newid()) FOR [TweetLocationID]
GO
ALTER TABLE [dbo].[TweetLocations] ADD  CONSTRAINT [DF_TweetLocations_Invalid]  DEFAULT ((0)) FOR [IsUpdated]
GO
ALTER TABLE [dbo].[Tweets] ADD  CONSTRAINT [DF_Tweets_ArePhrasesExtracted]  DEFAULT ((0)) FOR [ArePhrasesExtracted]
GO
ALTER TABLE [dbo].[TweetPhrases]  WITH CHECK ADD  CONSTRAINT [FK_TweetPhrases_Phrases] FOREIGN KEY([PhraseID])
REFERENCES [dbo].[Phrases] ([ID])
GO
ALTER TABLE [dbo].[TweetPhrases] CHECK CONSTRAINT [FK_TweetPhrases_Phrases]
GO
ALTER TABLE [dbo].[TweetPhrases]  WITH CHECK ADD  CONSTRAINT [FK_TweetPhrases_Tweets] FOREIGN KEY([TweetID])
REFERENCES [dbo].[Tweets] ([ID])
GO
ALTER TABLE [dbo].[TweetPhrases] CHECK CONSTRAINT [FK_TweetPhrases_Tweets]
GO
/****** Object:  StoredProcedure [dbo].[CreateBingLocation]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[CreateBingLocation]
(
	@LocationID UNIQUEIDENTIFIER,
	@JSON nvarchar(max)
)
AS
BEGIN

	if ISJSON(@JSON)=1
	begin

	declare @binglocation nvarchar(max)
	declare @BingLocationCountry nvarchar(max)

	set @binglocation = coalesce( JSON_VALUE(@JSON, '$.resourceSets[0].resources[0].address.adminDistrict2'), 
		JSON_VALUE(@JSON, '$.resourceSets[0].resources[0].address.locality'),
		JSON_VALUE(@JSON, '$.resourceSets[0].resources[0].address.formattedAddress'),
		JSON_VALUE(@JSON, '$.resourceSets[0].resources[0].address.adminDistrict')
	)
	
	set @BingLocationCountry = coalesce( JSON_VALUE(@JSON, '$.resourceSets[0].resources[0].address.countryRegion'), 
	JSON_VALUE(@JSON, '$.resourceSets[0].resources[0].address.formattedAddress')
	)
	
    update TweetLocations
	set 
	BingJSON = @JSON, 
	BingLocationCountry = @BingLocationCountry,
	BingLocation = @binglocation,
	BingPostCode = JSON_VALUE(@JSON, '$.resourceSets[0].resources[0].address.postalCode'),
	IsUpdated = 1
	where TweetLocationID = @LocationID
	end

	update TweetLocations
	set 	
	IsUpdated = 1
	where TweetLocationID = @LocationID

END
GO
/****** Object:  StoredProcedure [dbo].[CreateNewLocation]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateNewLocation]
(
    -- Add the parameters for the stored procedure here
	@location nvarchar(200)
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
	declare @count int
	select @count = count(*) FROM TweetLocations where TweetLocation = @location

	if @count = 0
	begin
		insert into TweetLocations( TweetLocationID, TweetLocation, IsUpdated)
		values ( NEWID(), @location,0 )
	end
END
GO
/****** Object:  StoredProcedure [dbo].[CreatePhrase]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[CreatePhrase]
(
    -- Add the parameters for the stored procedure here
    @Phrase nvarchar(100),
	@TweetID uniqueidentifier,
	@PhraseID uniqueidentifier output
)
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
   	declare @count int
	select @count = count(*) FROM Phrases where Phrase = @Phrase

	if @count = 0
	begin
	
		set @PhraseID = NEWID()

		insert into Phrases( ID, Phrase)
		values ( @PhraseID, @Phrase )

	end

	if @count > 0
	begin
	
		select @PhraseID =  ID
		from Phrases where Phrase = @Phrase
	end

	insert into TweetPhrases (ID, PhraseID, TweetID )
	select newid(), @PhraseID, @TweetID

END
GO
/****** Object:  StoredProcedure [dbo].[CreateTweet]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[CreateTweet]
(
    -- Add the parameters for the stored procedure here
	@body nvarchar(max),
	@sentiment nvarchar(max),
	@languagecode nvarchar(max),
	@twitterid nvarchar(max),
	@createdat nvarchar(max),
	@retweetcount nvarchar(max),
	@tweetedby nvarchar(max),
	@twitteruserid nvarchar(max),
	@location nvarchar(max),
	@runid uniqueidentifier
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	declare @count int
	select @count = count(*) from tweets where twitterid = @twitterid

	if @count = 0 and @twitterid <> ''
	begin
		insert into Tweets( ID, Body, Sentiment, TweetLanguageCode, TwitterID, CreatedAt, RetweetCount, TweetedBy, TwitterUserID, Location, runid, DateofTweet )
		select newid(), @body,@sentiment,@languagecode,@twitterid,@createdat,@retweetcount,@tweetedby,@twitteruserid, @location, @runid , CONVERT(datetime, @createdat) 

		return 1
	end

	return 0

END
GO
/****** Object:  StoredProcedure [dbo].[GetLatestTwitterID]    Script Date: 31/03/2020 08:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[GetLatestTwitterID]
(
	@LastTwitterID nvarchar(50) output
)
AS
BEGIN
	

	set @LastTwitterID = (select top 1 twitterid from tweets order by CreatedAt desc)

END
GO
INSERT [dbo].[LookupBadPhrases] ([Phrase]) VALUES (N'amp')
GO
INSERT [dbo].[LookupBadPhrases] ([Phrase]) VALUES (N'day')
GO
INSERT [dbo].[LookupBadPhrases] ([Phrase]) VALUES (N'days')
GO
INSERT [dbo].[LookupBadPhrases] ([Phrase]) VALUES (N'coronavirus')
GO
