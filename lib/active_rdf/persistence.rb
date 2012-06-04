module ActiveRDF
  module Persistence
    extend ActiveSupport::Concern

    included do

      # Override ActiveAttr::Attributes.attribute=(name, value)
      def attribute=(name, value)
        @attributes ||= {}
        # We'll assume that nil and "" are equivalent
        unless (@attributes[name].blank? && value.blank?) || (@attributes[name] == value)
          send("#{name}_will_change!")
        end
        @attributes[name] = value
      end
    end

    module ClassMethods

      def connection
        # TODO: make this behave like AM/AR Connection
        CLIENT
      end

      def create(attrs = nil) 
        object = new(attrs)
        object.save
        object
      end

      def create!(attrs = nil)
        object = new(attrs)
        object.save!
        object
      end

      def before_create(method)
        # Placeholder until implemented in ActiveRDF::Callbacks
      end

      def before_save(method)
        # Placeholder until implemented in ActiveRDF::Callbacks
      end

      # @see: http://rdf.rubyforge.org/RDF/Query/Solutions.html
      def order(variable)
      end

      def where(conditions)
      end

      def scope(variable, conditions)
      end

      def scoped
      end

      def count
        query = "SELECT COUNT(DISTINCT ?s) WHERE { GRAPH <#{self.graph}> { ?s a <#{self.type}> }}"
        result = CLIENT.select(query)
        result.first['callret-0'].to_i
      end

      def find(object_or_id, conditions = {})

        subject = case object_or_id
                  when String then decode(object_or_id)
                  when self then object_or_id.subject
                  else raise ActiveModel::MissingAttributeError.new(object_or_id.inspect)
                  end

        find_by_subject(subject, conditions = {})
      end      

      def first
        all(limit: 1).first
      end

      def execute(sql)
        results = []
        solutions = CLIENT.select(sql)
        solutions.each do |solution|
          record = new
          solution.each_binding do |name, value|
            record[name] = value.to_s
          end
          if record.subject.present?
            record.id = id_for(record.subject)
            record.changed_attributes.clear
          end
          results << record
        end
        results
      end

      # TODO: set baseurl via config
      def subject_for(id)
        RDF::URI('http://data.deichman.no') / self.name.downcase / "#" / id
      end

      def id_for(subject)
        subject.to_s.split("#").last
      end

      def destroy_all
        query = "CLEAR GRAPH <#{self.graph}>"
        CLIENT.clear(query)
      end
    end

    # Instance methods
    
    def connection
      self.class.connection
    end

    def save
      return false unless self.valid?
      create_or_update
    end

    def save!
      unless self.valid?
        raise ActiveRecord::RecordInvalid.new(self)
      end
      create_or_update
    end

    def destroy
      subject = subject_for(self.id)
      query = 
<<-q 
DELETE FROM <#{graph}> { <#{subject}> ?p ?o } 
WHERE { <#{subject}> ?p ?o }
q
      result = connection.delete(query)
    end


    def update_attributes(attributes)
      self.extend(::Transaction::Simple)
      status = false
      begin
        self.start_transaction
        self.assign_attributes(attributes)
        status = save
        self.commit_transaction
      rescue Exception
        self.rewind_transaction
        self.abort_transaction
      end
      status
    end

    def reload
      self.attributes = self.class.find(self).attributes
      self
    end

    def new_record?
      self.id.nil?
    end

    def persisted?
      !new_record?
    end

    def subject_for(id)
      self.class.subject_for(id)
    end

    private

    def create_or_update
      result = new_record? ? create : update
      result != false
    end

    def guid
      UUID.generate(:compact)
    end

  end
end
