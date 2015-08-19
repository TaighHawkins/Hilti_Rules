%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HORBURY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( horbury, `13 Setember2013` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-HORBURY` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100 ` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]


	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	,[q0n(line), get_type_of_supply ]

	,[q0n(line), get_suppliers_code_for_buyer ]

	,[q0n(line), get_delivery_note_number ]

	, delivery_party(`HORBURY BUILDING SYSTEMS LTD`)

%	,[q0n(line), get_delivery_location ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	,[q0n(line), get_due_date ]

	,[q0n(line), get_customer_comments]

	,[q0n(line), get_new_ship_to ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]

	, [ q0n(line), footer_line ]
	

] ).


%=======================================================================
i_line_rule_cut( footer_line, [ 
%=======================================================================

	  `sources`, `valid`, `on`

	, q0n(anything)

	, tab, narrative(s1), newline
	  
	, check(narrative(page) = 1)
	
	, trace([`Form Name`, narrative])

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_type_of_supply, [ 
%=======================================================================

	q0n(anything)

	,`delivery`, `time`, `:`, tab

	, dummy(s1), tab

	, type_of_supply(s1)

	, newline

	, trace( [ `type of supply`, type_of_supply ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	`sold`, `-`, `to`, tab

	, suppliers_code_for_buyer(s1)

	, tab, `delivery`, `time`

	, trace( [ `suppliers code for buyer`, suppliers_code_for_buyer ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_note_number, [
%=======================================================================

	`ship`, `-`, `to`, tab

	, or([ [ `NEW`, `SHIP`, `-`, `TO` , set(new_ship_to) ]

		, delivery_note_number(s1)

	 ])

	, trace( [ `delivery note number`, delivery_note_number ] ) 

] ).

%=======================================================================
i_rule( get_new_ship_to, [ 
%=======================================================================

	test(new_ship_to)

	, delivery_street_two_line

	, delivery_street_line

	, delivery_city_line

	, delivery_postcode_line

	, trace( [ `new ship to address`, delivery_city, delivery_postcode ] ) 

] ).

%=======================================================================
i_line_rule( delivery_street_two_line, [
%=======================================================================

	q0n(anything), `c`, `/`, `o`, q0n(anything)

	, q10( [ nearest_word(180,0,20), delivery_street_two(s) ] )

	, newline

	, trace( [ `delivery street two`, delivery_street_two] ) 

] ).


%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	nearest_word(180,0,20)

	, delivery_street(s)

	, q10([ check(i_user_check(gen_same, delivery_street_two, STREET)), delivery_street(STREET) ])

	, newline

	, trace( [ `delivery street`, delivery_street] ) 

] ).


%=======================================================================
i_line_rule( delivery_city_line, [
%=======================================================================

	nearest_word(180,0,20)

	, delivery_city(s)

	, newline

	, trace( [ `delivery city`, delivery_city] ) 

] ).

%=======================================================================
i_line_rule( delivery_postcode_line, [
%=======================================================================

	nearest_word(180,0,20)

	, delivery_postcode(s)

	, newline

	, trace( [ `delivery postcode`, delivery_postcode] ) 

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_location, [
%=======================================================================

	q0n(anything)

	,`job`, `no`, `.`, tab

	, delivery_location(s1)

	, newline

	, trace( [ `delivery location`, delivery_location ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`site`, `contact`, `:`, tab	

	, buyer_contact(s1)

	, newline

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`contact`, `phone`, `:`, tab

	, buyer_ddi(s1)

	, newline

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`email`, `:`, tab

	, buyer_email(s1)

	, newline

	, trace( [ `buyer email`, buyer_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	,`purchase`, `order`, `no`, `.`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	`authorised`, `:`

	, q0n(anything)

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%=======================================================================
i_line_rule( get_due_date, [ 
%=======================================================================

	q0n(anything)

	, `delivery`, `date`, `:`, tab

	, due_date(date)

	, newline

	, trace( [ `due date`, due_date ] ) 

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	customer_comments_header

	, customer_comments(``), shipping_instructions(``)

	, q(4, 0, customer_comments_line)

] ).

%=======================================================================
i_line_rule( customer_comments_header, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(special(w)),`special`

	, read_ahead(instructions(w)), `instructions`, `:`

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	nearest(special(start), 10, 10)

	, qn0([ read_ahead(dcc(w)), check(dcc(start) < instructions(end)), append(customer_comments(w), ``, ` `) ])

	, check(i_user_check(gen_same, customer_comments, CC)), shipping_instructions(CC)


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`sub`, `total`, tab, `£`, q10(tab)

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Item`, tab, `Description`, tab, `Min` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`sub`, `total`, tab

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_item(s1), tab

	, trace( [ `line item`, line_item ] )

	, line_descr(s1), tab

	, trace([ `line description`, line_descr ])

	, min_order_qty(d), tab

	, line_quantity_uom_code(s1), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, `£`, q10(tab), line_unit_amount_x(d), tab

	, per(d), tab

	, `£`, q10(tab), line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, newline

] ).