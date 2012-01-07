require './fraud.rb'

def test_email()
	emails = %w{user.name@email.com USERNAME@emAIl.com u.s.e.r.n.a.m.e+coups@eMAIL.com username+reallycoupons.really@email.com uSERnam.e@email.com username@email.com}

	emails.each do |email|
		puts flatten_email(email)
	end	
end

def test_street()
	streets = ["123 Grant Street", "123 Grant St.", "123 GRANT ST.", "123 gRAnT STREET", "123 grant street"]
	
	streets.each do |street|
		puts flatten_street(street)
	end
end

def test_state()
	states = ["NEW YORK", "new york", "neW YoRk", "New York", "NY", "nY","ny", "CALifornia", "california", "California", "CA", "ca", "IllInOiS", "Illinois", "il", "IL", "illinois"]
	
	states.each do |state|
		puts flatten_state(state)
	end
end


test_email
test_street
test_state