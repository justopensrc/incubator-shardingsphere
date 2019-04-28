/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

grammar DDLStatement;

import Symbol, Keyword, Literals, BaseRule;

createTable
    : CREATE createTableSpecification_ TABLE tableNotExistClause_ tableName createDefinitionClause_ inheritClause_
    ;

createIndex
    : CREATE createIndexSpecification_ INDEX concurrentlyClause_ (indexNotExistClause_ indexName)? ON onlyClause_ tableName 
    ;

alterTable
    : ALTER TABLE existClause_ onlyClause_ tableName asteriskClause_ alterDefinitionClause_
    ;

alterIndex
    : ALTER INDEX existClause_ indexName alterIndexDefinitionClause_
    ;

dropTable
    : DROP TABLE existClause_ tableNames
    ;

dropIndex
    : DROP INDEX (CONCURRENTLY)? existClause_ indexName (COMMA_ indexName)*
    ;
    
truncateTable
    : TRUNCATE TABLE? ONLY? tableNameParts
    ;

createTableSpecification_
    : ((GLOBAL | LOCAL)? (TEMPORARY | TEMP) | UNLOGGED)?
    ;

tableNotExistClause_
    : (IF NOT EXISTS)?
    ;

createDefinitionClause_
    : LP_ (createDefinition (COMMA_ createDefinition)*)? RP_
    ;

createDefinition
    : columnDefinition | tableConstraint | LIKE tableName likeOption*
    ;

columnDefinition
    : columnName dataType collateClause? columnConstraint*
    ;

columnConstraint
    : constraintClause? columnConstraintOption constraintOptionalParam
    ;

constraintClause
    : CONSTRAINT ignoredIdentifier_
    ;

columnConstraintOption
    : NOT? NULL
    | checkOption
    | DEFAULT defaultExpr
    | GENERATED (ALWAYS | BY DEFAULT) AS IDENTITY (LP_ sequenceOptions RP_)?
    | UNIQUE indexParameters
    | primaryKey indexParameters
    | REFERENCES tableName columnNames? (MATCH FULL | MATCH PARTIAL | MATCH SIMPLE)? (ON (DELETE | UPDATE) action)*
    ;

checkOption
    : CHECK expr (NO INHERIT)?
    ;

defaultExpr
    : CURRENT_TIMESTAMP | expr
    ;

sequenceOptions
    : sequenceOption+
    ;

sequenceOption
    : START WITH? NUMBER_
    | INCREMENT BY? NUMBER_
    | MAXVALUE NUMBER_
    | NO MAXVALUE
    | MINVALUE NUMBER_
    | NO MINVALUE
    | CYCLE
    | NO CYCLE
    | CACHE NUMBER_
    | OWNED BY
    ;

indexParameters
    : (USING INDEX TABLESPACE ignoredIdentifier_)?
    | INCLUDE columnNames
    | WITH
    ;

action
    : NO ACTION | RESTRICT | CASCADE | SET (NULL | DEFAULT)
    ;

constraintOptionalParam
    : (NOT? DEFERRABLE)? (INITIALLY (DEFERRED | IMMEDIATE))?
    ;

likeOption
    : (INCLUDING | EXCLUDING) (COMMENTS | CONSTRAINTS | DEFAULTS | IDENTITY | INDEXES | STATISTICS | STORAGE | ALL)
    ;

tableConstraint
    : constraintClause? tableConstraintOption constraintOptionalParam
    ;

tableConstraintOption
    : checkOption
    | UNIQUE columnNames indexParameters
    | primaryKey columnNames indexParameters
    | EXCLUDE (USING ignoredIdentifier_)?
    | FOREIGN KEY columnNames REFERENCES tableName columnNames? (MATCH FULL | MATCH PARTIAL | MATCH SIMPLE)? (ON (DELETE | UPDATE) action)*
    ;

inheritClause_
    : (INHERITS tableNames)?
    ;

createIndexSpecification_
    : UNIQUE?
    ;

concurrentlyClause_
    : CONCURRENTLY?
    ;

indexNotExistClause_
    : (IF NOT EXISTS)?
    ;

onlyClause_
    : ONLY?
    ;

existClause_
    : (IF EXISTS)?
    ;

asteriskClause_
    : ASTERISK_?
    ;

alterDefinitionClause_
    : alterTableActions | renameColumnSpecification | renameConstraint | renameTableSpecification_
    ;

alterIndexDefinitionClause_
    : renameIndexSpecification | alterIndexDependsOnExtension | alterIndexSetTableSpace
    ;

renameIndexSpecification
    : RENAME TO indexName
    ;

alterIndexDependsOnExtension
    : ALTER INDEX indexName DEPENDS ON EXTENSION ignoredIdentifier_
    ;

alterIndexSetTableSpace
    : ALTER INDEX ALL IN TABLESPACE indexName (OWNED BY ignoredIdentifiers_)?
    ;

tableNameParts
    : tableNamePart (COMMA_ tableNamePart)*
    ;

tableNamePart
    : tableName ASTERISK_?
    ;

alterTableActions
    : alterTableAction (COMMA_ alterTableAction)*
    ;

alterTableAction
    : addColumnSpecification
    | dropColumnSpecification
    | modifyColumnSpecification
    | addConstraintSpecification
    | ALTER CONSTRAINT ignoredIdentifier_ constraintOptionalParam
    | VALIDATE CONSTRAINT ignoredIdentifier_
    | DROP CONSTRAINT existClause_ ignoredIdentifier_ (RESTRICT | CASCADE)?
    | (DISABLE | ENABLE) TRIGGER (ignoredIdentifier_ | ALL | USER)?
    | ENABLE (REPLICA | ALWAYS) TRIGGER ignoredIdentifier_
    | (DISABLE | ENABLE) RULE ignoredIdentifier_
    | ENABLE (REPLICA | ALWAYS) RULE ignoredIdentifier_
    | (DISABLE | ENABLE | (NO? FORCE)) ROW LEVEL SECURITY
    | CLUSTER ON indexName
    | SET WITHOUT CLUSTER
    | SET (WITH | WITHOUT) OIDS
    | SET TABLESPACE ignoredIdentifier_
    | SET (LOGGED | UNLOGGED)
    | SET LP_ storageParameterWithValue (COMMA_ storageParameterWithValue)* RP_
    | RESET LP_ storageParameter (COMMA_ storageParameter)* RP_
    | INHERIT tableName
    | NO INHERIT tableName
    | OF dataTypeName_
    | NOT OF
    | OWNER TO (ignoredIdentifier_ | CURRENT_USER | SESSION_USER)
    | REPLICA IDENTITY (DEFAULT | (USING INDEX indexName) | FULL | NOTHING)
    ;

addColumnSpecification
    : ADD COLUMN? (IF NOT EXISTS)? columnDefinition
    ;

dropColumnSpecification
    : DROP COLUMN? existClause_ columnName (RESTRICT | CASCADE)?
    ;

modifyColumnSpecification
    : alterColumn (SET DATA)? TYPE dataType collateClause? (USING simpleExpr)?
    | alterColumn SET DEFAULT expr
    | alterColumn DROP DEFAULT
    | alterColumn (SET | DROP) NOT NULL
    | alterColumn ADD GENERATED (ALWAYS | (BY DEFAULT)) AS IDENTITY (LP_ sequenceOptions RP_)?
    | alterColumn alterColumnSetOption alterColumnSetOption*
    | alterColumn DROP IDENTITY existClause_
    | alterColumn SET STATISTICS NUMBER_
    | alterColumn SET LP_ attributeOptions RP_
    | alterColumn RESET LP_ attributeOptions RP_
    | alterColumn SET STORAGE (PLAIN | EXTERNAL | EXTENDED | MAIN)
    ;

alterColumn
    : ALTER COLUMN? columnName
    ;

alterColumnSetOption
    : SET (GENERATED (ALWAYS | BY DEFAULT) | sequenceOption) | RESTART (WITH? NUMBER_)?
    ;

attributeOptions
    : attributeOption (COMMA_ attributeOption)*
    ;

attributeOption
    : IDENTIFIER_ EQ_ simpleExpr
    ;

addConstraintSpecification
    : ADD (tableConstraint (NOT VALID)? | tableConstraintUsingIndex)
    ;

tableConstraintUsingIndex
    : (CONSTRAINT ignoredIdentifier_)? (UNIQUE | primaryKey) USING INDEX indexName constraintOptionalParam
    ;

storageParameterWithValue
    : storageParameter EQ_ simpleExpr
    ;

storageParameter
    : IDENTIFIER_
    ;

renameColumnSpecification
    : RENAME COLUMN? columnName TO columnName
    ;

renameConstraint
    : RENAME CONSTRAINT ignoredIdentifier_ TO ignoredIdentifier_
    ;

renameTableSpecification_
    : RENAME TO newTableName
    ;

newTableName
    : IDENTIFIER_
    ;
