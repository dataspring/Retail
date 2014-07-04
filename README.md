DataSpring
====================

Avantprise’s **DataSpring** is open source tool to generate realistic data for learning, modeling and testing in Machine Learning (ML). As numerous sources are available to get datasets in diverse domains, a realistic, dynamic and on demand data generator based on profile and controllable characteristics is a distant dream and DataSpring ventures to provide realistic test data at scale by developing a framework workable on a database (SQL Server for now) to cover every possible domains for which data could be generated realistically. 

Retail is the first domain and looking forward to contributors to discuss how to further abstract this or build a robust framework and make it available at large.

----------


DataSpring Retail
--------------
DataSpring Retail is a tool to generate huge amounts of data in a functional business domain i.e. Retail. This tool allows to generate transactions for customers profiled differently based on demography, income parity, age and gender to simulate actual retail transactions over a time period including daily, weekly, fortnightly, monthly, yearly and occasional (medical, celebratory, etc.) purchases with each customer having a set of regular buys plus randomly changing buys on top after a preset number of visits.
An **on demand** retail test data tool is available @ http://dataspring.avantprise.com.

###Getting Started

####Environment: 
Windows 7 and above with SQL Server Express 2012 and above 
####Steps:
 1. Download [BigTestData.rar](https://www.dropbox.com/s/jil120c26r9wz95/BigTestData.rar) and unzip to extract BigTestData.bak file. 
 2. Launch SQL Server Management Studio and connect to your flavor of SQL Server
 3. Restore this file to SQL Server as BigTestData database 
 4. Right click on this database and initiate a new query session
Run the following command to test drive the data generation process: 

###Retail Test Data on Demand
This test data is available on demand and you can visit http://dataspring.avantprise.com to send a profiled customer’s purchase pattern/history for few years by email to your inbox.
Do note that this is running on a micro instance in cloud and has its own throughput and data limits and use it responsibly.

### Big Test Data Generation
Executing step 5 will generate customer transaction for a single customer and iterating through entire customer base with an iteration script over all customers (nearly 100K) gives you sufficient data with different profiled customers.
BigTestData database has about 1000 different profiles, 100k customers, 130K product items and when applied to each customer whom may belong to any one profile will have a different product item pattern applied (regular buys and new buys are selected at random for each profile prior to generating the transactions). Hence you get every customer no matter how many customer you may have (thousands or millions), each of their purchase history’s product items will be different. 

###Documentation
Refer to wiki on the data entities and data generation design flow

###Next Version Features
To improve purchase history pattern to be more realistic and authentic – to be as real as possible to a supermarket, following areas can be further explored:

 - Increase or augment current feature set
	 - More product data inclusion (from current 130K to more)
	 - House hold types classifications can be increased (from current 5 to more)
	 - Age classification may be increased (from current 6 to more)
	 - Ad-hoc buys can be increased
	 - Festive buys can be re-looked
	 - Medical and other buys can be introduced
 - Add weather patterns
 - Add location based demographic distribution for customer age & gender
 - Introduce & explore on including following factors 
	 - product affinity to a location 
	 - pandemic/endemic diseases and social disorders 
	 - Major television ads push and campaigns
	 - Social Tastes, trends and diversions
	 - Games, Events may change buying pattern



----------