select * from dbo.vwCountries;



select distinct a.CountryCode, b.Name,case when b.CountryCode is null then 'N/A' else b.CountryCode end as countrycode
from [dbo].[SC_Subscription] as a left join dbo.vwCountries as b on a.CountryCode = b.Name
where len(a.countrycode) > 2;


select distinct a.CountryCode, b.Name,b.CountryCode
from [dbo].[SC_Subscription] as a left join dbo.vwCountries as b on a.CountryCode = b.CountryCode
where len(a.countrycode) = 2;


update [dbo].[SC_Subscription]
set CountryCode = case when b.CountryCode is null then 'N/A' else b.CountryCode end
from dbo.vwCountries as b
where [SC_Subscription].CountryCode = b.Name
and len([SC_Subscription].countrycode) > 2
and [SC_Subscription].ProcessedDate = '2020-02-11 19:47:33.890';

select distinct SubsidiaryName, CountryCode from [dbo].[SC_Subscription];

select count(1)  from [dbo].[SC_Subscription] where len(countrycode) > 2 and ProcessedDate = '2020-02-11 19:47:33.890';


select top 100 * from [dbo].[SC_Subscription];


begin tran
update [dbo].[SC_Subscription]
set CountryCode = case when b.CountryCode is null then 'NA' else b.CountryCode end
from [SC_Subscription] as a
left join dbo.vwCountries as b on a.CountryCode = b.Name
where  len(a.countrycode) > 2
and a.ProcessedDate = '2020-02-11 19:47:33.890';

select top 100 *   from [dbo].[SC_Subscription] where ProcessedDate = '2020-02-11 19:47:33.890' and len(countrycode) >2;

commit


begin tran
update [dbo].[SC_Subscription]
set CountryCode = case when c.newCountryCode is null then 'NA' else  c.newCountryCode  end
from (
select distinct a.CountryCode, b.Name, b.CountryCode as newCountryCode
from [dbo].[SC_Subscription] as a 
left join vwCountries as b on a.CountryCode = b.Name
where LEN(a.countrycode)>2
)
 as c
where [SC_Subscription].CountryCode = c.Name
and len([SC_Subscription].countrycode) > 2
and [SC_Subscription].ProcessedDate = '2020-02-11 19:47:33.890';

select *  from [dbo].[SC_Subscription] where len(countrycode) > 2 and ProcessedDate = '2020-02-11 19:47:33.890';

rollback




merge into [dbo].[SC_Subscription] as t
using vwCountries as s
on t.countrycode = s.name
when matched then update
set t.CountryCode = case when s.CountryCode is null then 'NA' else s.CountryCode end;







select distinct a.CountryCode, b.Name, b.CountryCode
from [dbo].[SC_Subscription] as a 
left join vwCountries as b on a.CountryCode = b.Name
where LEN(a.countrycode)>2;



select * from SC_Subscription_Workload