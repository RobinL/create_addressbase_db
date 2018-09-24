drop table if exists geographic_addresses;

CREATE TABLE geographic_addresses AS

SELECT  
b.uprn as uprn,
b.postcode_locator as postcode,
b.geom as geom,
CLASSIFICATION_CODE,


/*
Concatenate a single GEOGRAPHIC address line label

This code takes into account all possible combinations os pao/sao numbers and suffixes
*/
case
when o.organisation is not null then o.organisation||' ' else '' end
--Secondary Addressable Information-------------------------------------------------------------------------------------------------------
||case when l.sao_text is not null then l.sao_text||' ' else '' end
--case statement for different combinations of the sao start numbers (e.g. if no sao start suffix)
||case
when l.sao_start_number is not null and l.sao_start_suffix is null and l.sao_end_number is null
then l.sao_start_number::varchar(4)||' '
when l.sao_start_number is null then '' else l.sao_start_number::varchar(4)||'' end
--case statement for different combinations of the sao start suffixes (e.g. if no sao end number)
||case
when l.sao_start_suffix is not null and l.sao_end_number is null then l.sao_start_suffix||' '
when l.sao_start_suffix is not null and l.sao_end_number is not null then l.sao_start_suffix else '' end
--Add a '-' between the start and end of the secondary address (e.g. only when sao start and sao end)
||case
when l.sao_end_suffix is not null and l.sao_end_number is not null then '-'
when l.sao_start_number is not null and l.sao_end_number is not null then '-'else '' end
--case statement for different combinations of the sao end numbers and sao end suffixes
||case
when l.sao_end_number is not null and l.sao_end_suffix is null then l.sao_end_number::varchar(4)||' '
when l.sao_end_number is null then '' else l.sao_end_number::varchar(4) end
--pao end suffix
||case when l.sao_end_suffix is not null then l.sao_end_suffix||' ' else '' end
--Primary Addressable Information----------------------------------------------------------------------------------------------------------
||case when l.pao_text is not null then l.pao_text||' ' else '' end
--case statement for different combinations of the pao start numbers (e.g. if no pao start suffix)
||case
when l.pao_start_number is not null and l.pao_start_suffix is null and l.pao_end_number is null
then l.pao_start_number::varchar(4)||' '
when l.pao_start_number is null then ''
else l.pao_start_number::varchar(4)||'' end
--case statement for different combinations of the pao start suffixes (e.g. if no pao end number)
||case
when l.pao_start_suffix is not null and l.pao_end_number is null then l.pao_start_suffix||' '
when l.pao_start_suffix is not null and l.pao_end_number is not null then l.pao_start_suffix
else '' end
--Add a '-' between the start and end of the primary address (e.g. only when pao start and pao end)
||case
when l.pao_end_suffix is not null and l.pao_end_number is not null then '-'
when l.pao_start_number is not null and l.pao_end_number is not null then '-'
else '' end
--case statement for different combinations of the pao end numbers and pao end suffixes
||case
when l.pao_end_number is not null and l.pao_end_suffix is null then l.pao_end_number::varchar(4)||' '
when l.pao_end_number is null then ''
else l.pao_end_number::varchar(4) end
--pao end suffix
||case when l.pao_end_suffix is not null then l.pao_end_suffix||' ' else '' end
--Street Information----------------------------------------------------------------------------------------------------------------------------
||case when s.street_description is not null then s.street_description||' ' else '' end
--Locality------------------------------------------------------------------------------------------------------------------------------------------
||case when s.locality is not null then s.locality||' ' else '' end

--Town---------------------------------------------------------------------------------------------------------------------------------------------
||case when s.town_name is not null then s.town_name||' ' else '' end
--Postcode----------------------------------------------------------------------------------------------------------------------------------------
||case when b.postcode_locator is not null then b.postcode_locator else '' end
AS full_address

 
FROM 
abp_street_descriptor AS s, abp_classification as c,
abp_lpi as l full outer join abp_organisation AS o on (l.uprn = o.uprn),
abp_blpu AS b


--join tables
WHERE b.uprn = l.uprn
AND l.usrn = s.usrn
AND b.uprn = c.uprn
and ADDRESSBASE_POSTAL != 'N' ;



drop table if exists delivery_addresses;
create table delivery_addresses as 
SELECT
d.uprn as uprn,
postcode,
geom,
CLASSIFICATION_CODE,
(
 CASE WHEN department_name IS NOT NULL THEN department_name || ' ' ELSE '' END
 || CASE WHEN organisation_name IS NOT NULL THEN organisation_name || ' ' ELSE '' END
 || CASE WHEN sub_building_name IS NOT NULL THEN sub_building_name || ' ' ELSE '' END
 || CASE WHEN building_name IS NOT NULL THEN building_name || ' ' ELSE '' END
 || CASE WHEN building_number IS NOT NULL THEN building_number || ' ' ELSE '' END
 || CASE WHEN po_box_number IS NOT NULL THEN 'PO BOX ' || po_box_number || ' ' ELSE '' END
 || CASE WHEN dependent_thoroughfare IS NOT NULL THEN dependent_thoroughfare || ' ' ELSE '' END
 || CASE WHEN thoroughfare IS NOT NULL THEN thoroughfare || ' ' ELSE '' END
 || CASE WHEN double_dependent_locality IS NOT NULL THEN double_dependent_locality || ' ' ELSE '' END
 || CASE WHEN dependent_locality IS NOT NULL THEN dependent_locality  || ' ' ELSE '' END
 || CASE WHEN post_town IS NOT NULL THEN post_town || ' ' ELSE '' END
 || postcode
) AS full_address
FROM abp_delivery_point as d
left join abp_blpu as b
on d.uprn=b.uprn
left join abp_classification as c
on b.uprn = c.uprn;


drop table if exists all_addresses;
create table all_addresses as
select * from geographic_addresses
--Note we use union because this will remove duplicate rows.  union all would keep the dupes
union
select * from delivery_addresses;

CREATE INDEX idx_all_addresses_new_postcoderrr
  ON all_addresses_new
  USING btree
  (postcode);  

CREATE INDEX idx_all_addresses_new_uprn
  ON all_addresses_new
  USING btree
  (uprn); 

CREATE INDEX idx_all_addresses_new_geom
  ON all_addresses_new
  USING gist
  (geom); 

CREATE INDEX idx_all_addresses_fts_address ON all_addresses
USING gin(to_tsvector('english', full_address));

drop table if exists term_frequencies;
create table term_frequencies as
select word, 
count(*) as occurrences,
1.0000 as freq from 
(select regexp_split_to_table(upper(full_address), '[^\w]+|\s+') as word from all_addresses) as t
where word != ''
group by word
order by count(*) desc;

update term_frequencies
  set freq = occurrences/(select sum(occurrences) from term_frequencies);
  
CREATE INDEX idx_term_freqs_word
  ON term_frequencies
  USING btree
  (word);
  
  
  
  
