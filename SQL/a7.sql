use C;
/* Q1*/
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

/* Q2*/
select * from BATCH;
select * from FACTORY;

/* Q3*/

MERGE INTO [FACTORY] as fac 
using (select factory_id, factory,factory_sq_footage from factory_stage) as fac2 
on fac.factory_id = fac2.factory_id 
WHEN MATCHED THEN UPDATE 
SET fac.factory_sq_footage = fac2.factory_sq_footage 
WHEN NOT MATCHED THEN 
	INSERT (factory_id, factory,factory_sq_footage) 
	VALUES (fac2.factory_id, fac2.factory,fac2.factory_sq_footage);
	


MERGE INTO [BATCH] as bat 
using (select batch_id, factory_id,item_id, qty_in_batch from batch_stage) as bat2 
on bat.batch_id = bat2.batch_id 
WHEN MATCHED THEN UPDATE 
SET bat.qty_in_batch = bat2.qty_in_batch 
WHEN NOT MATCHED THEN 
	INSERT (batch_id, factory_id,item_id, qty_in_batch) 
	VALUES (bat2.factory_id, bat2.factory_id,bat2.item_id, bat2.qty_in_batch);


select * from BATCH;
select * from batch_stage;
select * from FACTORY;
select * from factory_stage;
