require 'pp'

class Racer
	include ActiveModel::Model

	# Attributes that allow to set/get each of the following properties:
	# id, number, first_name, last_name, gender, group and secs
	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	def to_s
    	"#{@id}: #{@number}, #{@first_name} #{@last_name}, #{@gender}, #{@group}, #{@secs}"
  	end

	#######################
	# Database Connection #
	#######################

	#convinience method for access to client in console
	def self.mongo_client
		Mongoid::Clients.default
	end

	#convinience method for access to racer collection
	def self.collection
		self.mongo_client['racers']
	end

	######################
	# CRUD Model Methods #
	######################

  	# Initializer that can set the properties of the class using the keys from a racers document. 
  	# It must:
  	# - Accept a hash of properties
	# - Assign instance attributes to the values from the hash
	# - For the id property, it tests whether the hash is coming from a web page [:id] 
	# or from a MongoDB query [:_id] and assign the value to whichever is non-nil.
	def initialize(params={})
	    #switch between both internal and external views of id and population
	    @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
		@number=params[:number].to_i
		@first_name=params[:first_name]
		@last_name=params[:last_name]
		@gender=params[:gender]
		@group=params[:group]
		@secs=params[:secs].to_i
	end

	# Class method all. This method must:
	# - Accept an optional prototype, optional sort, optional skip, and optional limit. 
	# 		The default for the prototype is to “match all” – which means you must provide it 
	# 		a document that matches all records. 
	# 		The default for sort must be by number ascending. 
	# 		The default for skip must be 0 
	# 		The default for limit must be nil.
	# - Find all racers that match the given prototype
	# - Sort them by the given hash criteria
	# - Skip the specified number of documents
	# - Limit the number of documents returned if limit is specified
	# - Return the result	
	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)
		result=collection.find(prototype)
			.sort(sort)
			.skip(skip)
    	result=result.limit(limit) if !limit.nil?
	    return result	
	end

	# Class method find. This method must:
	# - Accept a single id parameter that is either a string or BSON::ObjectId 
	# Note: it must be able to handle either format.
	# -Find the specific document with that _id
	# -Return the racer document represented by that id
	def self.find id
		result=collection.find(:_id => BSON::ObjectId.from_string(id)).first
		return result.nil? ? nil : Racer.new(result)
	end

	# Instance method save. 
	# Creates a new document using the current instance.
	# This method must:
	# - Take no arguments
	# - Insert the current state of the Racer instance into the database
	# - Obtain the inserted document _id from the result and assign the 
	# to_s value of the _id to the instance attribute @id	
	def save
		result=self.class.collection
			.insert_one(number:@number, first_name:@first_name, last_name:@last_name, gender:@gender, group:@group, secs:@secs)
		@id=result.inserted_id.to_s	
	end

	# Instance method update. This method must:
	# - Accept a hash as an input parameter
	# - Updates the state of the instance variables – except for @id. That never should change.
	# - Find the racer associated with the current @id instance variable in the database
	# - Update the racer with the supplied values – replacing all values
	def update(params)
		@number=params[:number].to_i
		@first_name=params[:first_name]
		@last_name=params[:last_name]
		@gender=params[:gender]
		@group=params[:group]
		@secs=params[:secs].to_i

		params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
		self.class.collection
			.find(:_id=>BSON::ObjectId.from_string(@id))
			.replace_one(params)
	end

	# Instance method destroy. This method must:
	# - Accept no arguments
	# - Find the racer associated with the current @number instance variable in the database
	# - Remove that instance from the database
	def destroy
		self.class.collection
			.find(number:@number)
			.delete_one
	end

	######################################
	#  Completing Active Model Framework #
	######################################

  	# Instance method persisted?. 
  	# Check to see if the primary key has been assigned.
  	# This method must:
	# - Accept no arguments
	# - Return true when @id is not nil. 
	# Remember – we assigned @id during save when we obtained the generated primary key.
	def persisted?
		!@id.nil?
	end

	# Two instance methods called created_at and updated_at that act as placeholders for property getters. 
	# JSON marshalling will expect these two methods to be there by default.
	# They must:
	# - Accept no arguments
	# - Return nil or whatever date you would like. 
	# This is, of course, just a placeholder until we implement something that does this for real.
	def created_at
		nil
	end
	def updated_at
		nil
	end

	######################
	#  Adding pagination #
	######################

	# Add a class method to the Racer class called paginate. This method must:
	# - Accept a hash as input parameters
	# - Extract the :page property from that hash, convert to an integer, 
	#   and default to the value of 1 if not set.
	# - Extract the :per_page property from that hash, convert to an integer, 
	#   and default to the value of 30 if not set
	# - Find all racers sorted by number assending.
	# - Limit the results to page and limit values.
	# - Convert each document hash to an instance of a Racer class
	# - Return a WillPaginate::Collection with the page, limit, 
	#   and total values filled in – as well as the page worth of data.
	def self.paginate(params)
		page=(params[:page] || 1).to_i
		limit=(params[:per_page] || 30).to_i
		skip=(page-1)*limit
		sort = {:number => 1}
		racers=[]
		all({}, sort, skip, limit).each do |doc|
      		racers << Racer.new(doc)
    	end		
		total=collection.count
		WillPaginate::Collection.create(page, limit, total) do |pager|
			pager.replace(racers)
		end
	end
end