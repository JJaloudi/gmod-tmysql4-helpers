//Easy helper functions for the tmysql4 module.
//Hope it's useful to you, cheers! 

database = { 
	_obj = db // This should be whatever your global reference to your database object is.
 } 

//Converts a table into a query string. i.e. ["steamid"] = ply:SteamID() -> steamid='STEAM_0:1:22482189'
database.QueryString = function(val)
	if (type(val) == "table") then
		local queryString = "";
		local iterator = 0;
			
		for key,value in pairs(val) do
			iterator = iterator + 1;
				
			if (iterator == table.Count(val)) then
				queryString = queryString .. key .. "='" .. value .. "'"
			else
				queryString = queryString .. key .. "='" .. value .. "', "
			end
		end 
			
		return queryString
	end
		
	return val
end

//Converts a table into a data string. Useful for setting up tables and specifying their data types. i.e. ["steamid"] = "int NOT NULL" -> steamid int NOT NULL
database.DataString = function(val) 
	if (type(val) == "table") then
		local dataString = "";
		local iterator = 0;
			
		for key,value in pairs(val) do
			iterator = iterator + 1;
				
			if (iterator == table.Count(val)) then
				dataString = dataString .. key .. " " .. value 
			else
				dataString = dataString .. key .. " " .. value .. ", "
			end
		end
			
		return dataString
	end
		
	return val
end

//Converts a table into a key/value string. Useful for inserting into tables, as it returns the keys that must go into the key column as well as their value partners.
// i.e. ["steamid"] = "STEAM_0:1:22482189" -> INSERT INTO players (data.key -> steamid) VALUES (data.value -> STEAM_0:1:22482189)
database.KeyValue = function(val)
	if (type(val) == "table") then
		local keyString = "";
		local valueString = "";
		local iterator = 0;
			
		for key,value in pairs(val) do
			iterator = iterator + 1;
				
			if (iterator == table.Count(val)) then
				valueString = valueString .. "'" .. value .. "'"
				keyString = keyString  .. key 
			else
				valueString = valueString .. "'" .. value  .. "', "
				keyString = keyString .. key .. ", "
			end
		end
			
		return {value = valueString, key = keyString}
	end
		
	return val
end

//Arguments List:
//name -> name of table.
//data -> data you're inserting.
//callback -> function called AFTER query status is complete.
//req -> data you're requesting from where clause.
//where -> specifications of where you're looking.
//value -> value you're updating target to.

//ALL of these functions use the conversion methods stated above, therefore - most arguments request tables unless you're inputting
//a properly formatted string already.

database.Create = function(name, data, callback)
	
	_obj:Query("CREATE TABLE "..name.." ("..database.DataString(dataTbl)..")", callback)
		
end

database.Insert = function(name, data, callback)
	data = database.KeyValue(data)
	
	_obj:Query("INSERT INTO " .. name .. " (" .. data.key .. ") VALUES (" .. data.value .. ")", callback)
end
	
database.Drop = function(name, callback)
	
	if callback then callback() end
	
end
	
database.TableExists = function(name, callback)
	_obj:Query("SELECT * FROM "..name, function( results )
		PrintTable(results)
		callback(results[1].data != nil)
	end)
end 

database.Where = function(name, req, data, callback) 
	_obj:Query("SELECT " .. req .. " FROM " .. name .. " WHERE " .. database.QueryString(data), callback)
end
	 
database.Update = function(name, where, value, callback)		
	print("UPDATE "..name.." SET ".. database.QueryString(value) .." WHERE ".. database.QueryString(where))
	_obj:Query("UPDATE "..name.." SET ".. database.QueryString(value) .." WHERE ".. database.QueryString(where), callback)
end

database.Seed = function()
	//Handle all necessary seeding inside of here.
	database.TableExists("player", function(exists)
		if !exists then
			database.Create("player", {
			["userid"] = "int NOT NULL AUTO_INCREMENT", 
			["steamid"] = "varchar(32)",
			["wallet"] = "int DEFAULT 0",
			["bank"] = "int DEFAULT 500",
			["PRIMARY KEY"] = "(userid)"}, function( results )
				PrintTable( results )
			end)
		end
	end)
end

hook.Add("Initialize", "Seeding", function()
	database.Seed();	
end)
