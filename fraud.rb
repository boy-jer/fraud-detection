# My basic thinking on this:
# Within each deal, put the flattened addresses and emails in hash maps
# and check for repeats.
# 
# Oh, I'm re-learning ruby at the same time I'm doing this coding challenge.  
# Trying to call two birds with one stone.  Yeah...

$deals = Array.new
$fraud_list = Array.new

#flatten variations of email addresses into the same thing
# eg bugs.BUNNY+groupon@gmail.com -> bugsbunny@gmail.com
def flatten_email(email)
	#split account part
	at_pos = email.index('@')	
	e = email.slice(0, at_pos)
	
	#remove +postfix
	if plus_pos = e.index('+')				
		e = e.slice(0, plus_pos)
	end
		
	#remove periods from account part
	e.delete!('.')
	
	#rejoin with @domain	
	e = e + email.slice(at_pos, email.length)
	
	#case insensitive
	e.downcase!	
		
	#return
	e	
end

#flatten street variations into the same thing
# eg StReEt -> st
# eg ST -> st
def flatten_street(street)
	#case insensitive
	s = street.downcase

	#road abbreviation insensitive
	s.sub!("road", 'rd.')
	s.sub!("street", 'st.')
	
	#return
	s	
end

#flatten state variations into the same thing
#eg cALIFORNIA -> ca
#eg IL -> il
def flatten_state(state)
	#case insensitive, state abbreviation insensitive	
	s = state.downcase
	
	#state abbreviation insensitive
	s.sub!("illinois", 'il')
	s.sub!("california", 'ca')
	s.sub!("new york", 'ny')
	
	#return
	s	
end

#Determine  if two records constitute fraudulent orders
# They either have:
# 	the same deal, same email, and differing credit card
# or:
# 	the same deal, same address, and differing credit card
def records_fraudulent?(a, b)
	result = false
	
	if a.deal == b.deal		
		if a.email == b.email
			if a.cc != b.cc
				result = true
			end
		end	
		if a.address == b.address
			if a.cc != b.cc
				result = true
			end
		end
	end
	
	result
end

class Deal
	attr_accessor :deal, :records, :haddresses, :hemails

	def initialize(deal)
		@records = Hash.new	# key: order id. value: record
		@haddresses = Hash.new # key: address. value: order id
		@hemails = Hash.new # key: email. value: order id
	
		@deal = deal	# deal id
	end
	
	def add_record(record, address, email)
		@records[record.order] = record
				
		#add address to hash map or check fraud
		if matched_order = @haddresses.fetch(address, false)
			#match, check for fraud
			if records_fraudulent?( @records[matched_order], record)	
				$fraud_list << matched_order << record.order
			end
		else	
			@haddresses[address] = record.order
		end
		
		#add email to hash map or check fraud
		if matched_order = @hemails.fetch(email, false)
			#match, check for fraud			
			if records_fraudulent?( @records[matched_order], record)
				$fraud_list << matched_order << record.order
			end
		else	
			@hemails[email] = record.order
		end
		
	end
end

class Record
	attr_accessor :order, :deal, :email, :address, :cc

	def initialize(order, deal, email, address, cc)
		@order = order
		@deal = deal
		@email = email
		@address = address
		@cc = cc	
	end
end

def check
	#store the record count, not that we need it for anything
	count = STDIN.gets

	#repeatedly get new record lines
	while line = STDIN.gets
		line = line.chomp.split(',')
		
		order		= line[0]
		deal	 	= line[1]
		email	 	= line[2]
		street 	= line[3]
		city 		= line[4]
		state		= line[5]
		zip			= line[6]
		cc			= line[7]
		
		#convert these to integers so we can use them as indices
		order = order.to_i
		deal = deal.to_i
		
		#flatten things and lowercase
		email = flatten_email(email)	
		street = flatten_street(street)
		city = city.downcase!
		state = flatten_state(state)
		
		address = street + city + state + zip
		
		#create a record object
		record = Record.new(order, deal, email, address, cc)
						
		if $deals.fetch(deal, nil).nil?
			$deals[deal] = Deal.new(order)		
		end
		
		$deals[deal].add_record(record, address, email)	
	end
	
	puts $fraud_list.uniq.sort.join(',')
end

check