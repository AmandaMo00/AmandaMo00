# SQL microsoft 
## Requirements  


1. Referring to the model developed in Assignment 6, create a factory and a batch table using the code in Appendix B.  This code will also insert sample data for each table. 2. Use the two provided files (batch_stage.csv and factory_stage.csv) to create two new tables and populate them with data. 3. Write MERGE statements that synchronize each pair of tables (batch synchronizes with batch_stage, factory synchronizes with factory_stage) by inserting and updating.  The batch and factory tables should house the most complete and updated data after the MERGE statements are executed.  Be sure to put the MERGE statements in the correct order. 4. Submit the two MERGE statements in one .SQL file before the deadline.   


/*CREATING BATCH & FACTORY */  
CREATE TABLE [dbo].[FACTORY](
[factory_id] [int] NOT NULL,
[factory] [nvarchar](200) NOT NULL,
[factory_sq_footage] [int] NOT NULL,
CONSTRAINT [PK_FACTORY] PRIMARY KEY CLUSTERED
(
[factory_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
CREATE TABLE [dbo].[BATCH](
[batch_id] [int] NOT NULL,
[factory_id] [int] NOT NULL,
[item_id] [int] NOT NULL,
[qty_in_batch] [int] NOT NULL,
CONSTRAINT [PK_BATCH] PRIMARY KEY CLUSTERED
(
[batch_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[BATCH] WITH CHECK ADD CONSTRAINT [FK_BATCH_factory_id] FOREIGN
KEY([factory_id])
REFERENCES [dbo].[FACTORY] ([factory_id])
INSERT [dbo].[FACTORY] ([factory_id], [factory], [factory_sq_footage]) VALUES (1,
'Portland', 6000)
INSERT [dbo].[FACTORY] ([factory_id], [factory], [factory_sq_footage]) VALUES (2,
'Tucson', 8700)
INSERT [dbo].[BATCH] ([batch_id], [factory_id], [item_id], [qty_in_batch]) VALUES (8848,
1, 1, 20)
INSERT [dbo].[BATCH] ([batch_id], [factory_id], [item_id], [qty_in_batch]) VALUES (3911,
2, 1, 30)
INSERT [dbo].[BATCH] ([batch_id], [factory_id], [item_id], [qty_in_batch]) VALUES (6697,
1, 2, 60)
INSERT [dbo].[BATCH] ([batch_id], [factory_id], [item_id], [qty_in_batch]) VALUES (6698,
2, 2, 60)
;
  
# ???
