require 'zlib'

def flatten_email(email)
	#split account part
	at_pos = email.index('@')	
	e = email.slice(0, at_pos)
	
	#remove +postfix
	plus_pos = e.index('+')
	e.slice!(0, plus_pos)
		
	#remove periods from account part
	e.delete!('.')
	
	#case insensitive
	e.downcase!	
	
	#return
	e	
end

def flatten_street(street)
	#case insensitive
	s.downcase(street_address)

	#road abbreviation insensitive
	s.sub!("road", 'rd')
	s.sub!("street", 'st')
	
	#return
	s	
end

def flatten_state(state)
	#case insensitive, state abbreviation insensitive	
	s.downcase(state)
	
	#state abbreviation insensitive
	s.sub!("illinois", 'il')
	s.sub!("california", 'ca')
	s.sub!("new york", 'ny')
	
	#return
	s	
end

def records_fraudulent?(a, b)
	result = false
	
	if a.deal == b.deal		
		if a.email == b.email
			if a.cc != b.cc
				result = true
		if a.address == b.address
			if a.cc != b.cc
				result = true

	result
end

class Deal
	@records = {}
	@haddresses = {}
	@hemails = {}
	
	def new(deal)
		self.deal = deal
	end
	
	def add_record(record, address_crc, email_crc)
		@records[record.order] = record
				
		#add crc to address hash map or check fraud
		if matched_order = @haddresses.fetch(address_crc, false)
			#collision, check for fraud
			if record_fraudulent?( @records[matched_order], record)	
				fraudulent << matched_order << record.order
			end
		else	
			@haddresses[address_crc] = record[0]
		end
		
		#add crc to email hash map or check fraud
		if matched_order = @hemails.fetch(email_crc, false)
			#collision, check for fraud			
			if record_fraudulent?( @records[matched_order], record)
				fraudulent << matched_order << record.order
			end
		else	
			@hemails[email_crc] = record[0]
		end
		
	end
end

class Record
	def new(order, deal, email, address, cc)
		self.order = order
		self.deal = deal
		self.email = email
		self.address = address
		self.cc = cc	
	end
end

count = STDIN.gets

deals = []
fraud_list = []

while line = STDIN.gets
	line.split!(',')
	
	order		= line[0]
	deal	 	= line[1]
	email	 	= line[2]
	street 	= line[3]
	city 		= line[4]
	state		= line[5]
	zip			= line[6]
	cc			= line[7]
	
	email = flatten_email(email)	
	street = flatten_street(street)
	city = city.downcase!
	state = flatten_state(state)	
		
	record = Record.new(order, deal, email, street+city+state+zip, cc)
	
	address_crc = Zlib::crc32( street + city + state + zip + deal )	
	email_crc = Zlib::crc32( email + deal )
	
	if !deals.fetch(order, false)
		deals[order] = Deal.new(order)		
	end
	
	deals[order].add_record(record, address_crc, email_crc)
	
	puts fraud_list.join(",")
end

