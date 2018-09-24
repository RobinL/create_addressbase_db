----BLPU

CREATE INDEX idx_blpu_uprn
  ON abp_blpu
  USING btree
  (uprn);

CREATE INDEX idx_blpu_custodian
  ON abp_blpu
  USING btree
  (local_custodian_code);

 CREATE INDEX idx_blpu_postcode
  ON  abp_blpu
  USING btree
  (postcode_locator); 

ALTER TABLE  abp_blpu ADD PRIMARY KEY (uprn);

ALTER TABLE abp_blpu ADD COLUMN arc_id serial ;

CREATE INDEX idx_arc_id_blpu
  ON abp_blpu
  USING btree
  (arc_id);

SELECT AddGeometryColumn ('public', 'abp_blpu', 'geom', 27700, 'POINT', 2);

UPDATE abp_blpu SET geom = ST_GeomFromText('POINT(' || x_coordinate || ' ' || y_coordinate || ')', 27700 );

CREATE INDEX idx_geom_blpu ON abp_blpu USING gist(geom);

----delivery point

CREATE INDEX idx_dpa_postcode
  ON abp_delivery_point
  USING btree
  (postcode);



CREATE INDEX idx_dpa_thoroughfare
  ON abp_delivery_point
  USING btree
  (thoroughfare);  

CREATE INDEX idx_dpa_uprn
  ON abp_delivery_point
  USING btree
  (uprn);    
  
CREATE INDEX idx_dpa_post_town
  ON abp_delivery_point
  USING btree
  (post_town);
  

CREATE INDEX idx_dpa_organisation
  ON abp_delivery_point
  USING btree
  (organisation_name);  

ALTER TABLE abp_delivery_point ADD PRIMARY KEY (uprn);  

----LPI

CREATE INDEX idx_lpi_uprn
  ON abp_lpi
  USING btree
  (uprn);

CREATE INDEX idx_lpi_pao_text
  ON abp_lpi
  USING btree
  (pao_text);    
  
CREATE INDEX idx_lpi_sao_text
  ON abp_lpi
  USING btree
  (sao_text);  
  
CREATE INDEX idx_lpi_area_name
  ON abp_lpi
  USING btree
  (area_name);  
  
ALTER TABLE abp_lpi ADD PRIMARY KEY (lpi_key);


----cross_reference

CREATE INDEX idx_xref_uprn
  ON abp_crossref
  USING btree
  (uprn); 

CREATE INDEX idx_xref_source
  ON abp_crossref
  USING btree
  (source); 
  
CREATE INDEX idx_xref_cross_reference
  ON abp_crossref
  USING btree
  (cross_reference); 

ALTER TABLE abp_crossref ADD PRIMARY KEY (xref_key); 



----classification

CREATE INDEX idx_class_classification
  ON abp_classification
  USING btree
  (classification_code);
  

CREATE INDEX idx_class_uprn
  ON abp_classification
  USING btree
  (uprn);
  
ALTER TABLE abp_classification ADD PRIMARY KEY (class_key);


----street

CREATE INDEX idx_usrn__street
  ON abp_street
  USING btree
  (usrn); 

ALTER TABLE abp_street ADD PRIMARY KEY (usrn); 

----street descriptor

CREATE INDEX idx_street_descriptor_usrn
  ON abp_street_descriptor
  USING btree
  (usrn); 

CREATE INDEX idx_street_descriptor_townname
  ON abp_street_descriptor
  USING btree
  (town_name); 

CREATE INDEX idx_street_descriptor_locality_name
  ON abp_street_descriptor
  USING btree
  (LOCALITY); 

CREATE INDEX idx_street_description_street_description
  ON abp_street_descriptor
  USING btree
  (street_description); 
  
-- This is not unique in later versions of postgres so best not to run the following statement
--ALTER TABLE abp_street_descriptor ADD PRIMARY KEY (usrn); 

ALTER TABLE abp_street_descriptor SET WITH OIDS;

----organisation

CREATE INDEX idx_organisation_organisation
  ON abp_organisation
  USING btree
  (organisation);  

CREATE INDEX idx_organisation_uprn
  ON abp_organisation
  USING btree
  (uprn); 

 ALTER TABLE abp_organisation ADD PRIMARY KEY (org_key); 
 
 ALTER TABLE abp_organisation SET WITH OIDS;
 
 
 
 