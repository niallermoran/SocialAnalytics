/****** Object:  Table [dbo].[Tweets]    Script Date: 26/03/2020 09:45:15 ******/
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
 CONSTRAINT [PK_Tweets] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[viewTweets]    Script Date: 26/03/2020 09:45:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewTweets]
AS
SELECT        ID, Body, Sentiment, TweetLanguageCode, TwitterID, RetweetCount, TweetedBy, TwitterUserID, Location, BingLocation, CONVERT(datetime, CreatedAt) AS DateCreated, OriginalTwitterUser, OriginalTweetID, RunID
FROM            dbo.Tweets
WHERE        (Location <> '')
GO
/****** Object:  Table [dbo].[TweetPhrases]    Script Date: 26/03/2020 09:45:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TweetPhrases](
	[ID] [uniqueidentifier] NOT NULL,
	[Phrase] [nvarchar](max) NOT NULL,
	[TweetID] [nvarchar](50) NOT NULL,
	[Language] [nvarchar](max) NOT NULL,
	[RunID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TweetPhrases] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[viewPhrases]    Script Date: 26/03/2020 09:45:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewPhrases]
AS
SELECT        TOP (100) PERCENT ID, Phrase, TweetID, Language, { fn LENGTH(Phrase) } AS Size, RunID
FROM            dbo.TweetPhrases
WHERE        ({ fn LENGTH(Phrase) } > 2)
GO
/****** Object:  View [dbo].[viewGetLatestTweet]    Script Date: 26/03/2020 09:45:15 ******/
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
/****** Object:  Table [dbo].[TweetLocations]    Script Date: 26/03/2020 09:45:15 ******/
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
/****** Object:  View [dbo].[viewLocations]    Script Date: 26/03/2020 09:45:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[viewLocations]
AS
SELECT        TweetLocationID, TweetLocation, BingLocationCountry, BingLocation, BingPostCode, IsUpdated, BingJSON
FROM            dbo.TweetLocations
GO
/****** Object:  View [dbo].[viewNoBingLocations]    Script Date: 26/03/2020 09:45:15 ******/
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
/****** Object:  Table [dbo].[Runs]    Script Date: 26/03/2020 09:45:15 ******/
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
 CONSTRAINT [PK_Runs] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TweetLocations] ADD  CONSTRAINT [DF_TweetLocations_TweetLocationID]  DEFAULT (newid()) FOR [TweetLocationID]
GO
ALTER TABLE [dbo].[TweetLocations] ADD  CONSTRAINT [DF_TweetLocations_Invalid]  DEFAULT ((0)) FOR [IsUpdated]
GO
/****** Object:  StoredProcedure [dbo].[CreateBingLocation]    Script Date: 26/03/2020 09:45:15 ******/
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
END
GO
/****** Object:  StoredProcedure [dbo].[CreateNewLocation]    Script Date: 26/03/2020 09:45:15 ******/
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
/****** Object:  StoredProcedure [dbo].[CreateTweet]    Script Date: 26/03/2020 09:45:15 ******/
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

	if @count = 0
	begin
		insert into Tweets( ID, Body, Sentiment, TweetLanguageCode, TwitterID, CreatedAt, RetweetCount, TweetedBy, TwitterUserID, Location, runid )
		select newid(), @body,@sentiment,@languagecode,@twitterid,@createdat,@retweetcount,@tweetedby,@twitteruserid, @location, @runid 

		return 1
	end

	return 0

END
GO
/****** Object:  StoredProcedure [dbo].[GetLatestTwitterID]    Script Date: 26/03/2020 09:45:15 ******/
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
