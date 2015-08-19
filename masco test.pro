%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MASCO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( masco, `23 June 2014` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( 'm/d/y' ).

i_format_postcode( X, X ).

i_op_param( orders05_idocs_first_and_last_name( delivery_party, Name1, `` ), _, _, _ )
:- grammar_set( alternate_name ), result( _, invoice, delivery_party, Name1 ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, customer_comments( `Customer Comments` )

	, type_of_supply(`01`)

	, cost_centre(`Standard`)
	
	, [ q0n(line), customer_comments_line ] 

	, [ q0n(line), shipping_instructions_line ] 

	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	, delivery_ddi(`9999999999`)

	, buyer_ddi(`9999999999`)	


	, get_delivery_contact

	,[q0n(line), get_delivery_address ]
	
	, [ without( delivery_party ), delivery_party( `Copy Address from PO` ), set( alternate_name ) ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_revision_number ]

	,[q0n(line), get_order_date_1 ]

	,[q0n(line), get_order_date_2 ]

	,[q0n(line), buyer_contact_line ]

	,[q0n(line), get_buyer_contact_2 ]

	, get_invoice_lines

	,[ q0n(line), without( delivery_note_reference ), get_invoice_totals]

	, or([ get_test_suppliers_code_for_buyer, suppliers_code_for_buyer( `10478727` ) ])    % TEST
	, or([ get_suppliers_code_for_buyer, suppliers_code_for_buyer( `10837445` ) ])    % PROD


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( customer_comments_line, [ 
%=======================================================================

	shipping_instructions_header_line

	, get_customer_comments_line

	, q10( read_ahead(find_email_address) )

	, q(3,0, append_customer_comments)

]).

%=======================================================================
i_rule( find_email_address, [ 
%=======================================================================

	q(0,3,line)

	, delivery_email_address


]).

%=======================================================================
i_line_rule( delivery_email_address, [ 
%=======================================================================

	q10([word, q01(`:`), tab, q01(`:`)])	

	, q0n(word)

	, delivery_email(w), qn0([ `.`, append(delivery_email(w), `.`, ``) ])

	, `@`

	, or([ [ append(delivery_email(s), `@`, `` ), `.` , or([ space, tab, newline ]) ]

		, [ append(delivery_email(s), `@`, `` ), or([ space, tab, newline ]) ] ])


	%, q0n([ `.`, append(delivery_email( f( [ begin, q(alpha,1,10), end, q(other("."),1,1)  ])  )  , `.`, ``) ])


]).

%=======================================================================
i_line_rule( customer_comments_header_line, [ 
%=======================================================================

	dummy(w)

	,`deliver`, `to`, `:`

	, check(dummy(y) < -70)

	, trace( [ `customer comments`,  customer_comments ] )

]).

%=======================================================================
i_line_rule( get_customer_comments_line, [ 
%=======================================================================

	nearest_word(-280, 20, 20)

%	, q10(read_ahead( buyer_email_address))

	, customer_comments(s)

	, newline

	, trace( [ `customer comments`,  customer_comments ] )

]).

%=======================================================================
i_line_rule( append_customer_comments, [ 
%=======================================================================

	nearest_word(-280, 20, 20)

%	, q10(read_ahead( buyer_email_address))

	, append(customer_comments(s), ` `, ``)

	, newline

	, trace( [ `customer comments`,  customer_comments ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( shipping_instructions_line, [ 
%=======================================================================

	shipping_instructions_header_line

	, get_shipping_instructions_line

	, q(3,0, append_shipping_instructions)

]).

%=======================================================================
i_line_rule( shipping_instructions_header_line, [ 
%=======================================================================

	read_ahead(dummy(w))

	, check(dummy(y) < -70)

	,`deliver`, `to`, `:`

	, trace( [ `shipping instructions`,  shipping_instructions ] )

]).

%=======================================================================
i_line_rule( get_shipping_instructions_line, [ 
%=======================================================================

	nearest_word(-280, 20, 20)

	%, q10(read_ahead( buyer_email_address))

	, shipping_instructions(s)

, newline

	, trace( [ `shipping instructions`,  shipping_instructions ] )

]).

%=======================================================================
i_line_rule( append_shipping_instructions, [ 
%=======================================================================

	nearest_word(-280, 20, 20)

	%, q10(read_ahead( buyer_email_address))

	, append(shipping_instructions(s), ` `, ``)

	, newline

	, trace( [ `shipping instructions`,  shipping_instructions ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  delivery_header_line

	, qn0( gen_line_nothing_here( [ delivery_party(start), 10, 10 ] ) )
	
	, delivery_thing_line( [ ( delivery_dept, s1 ) ] )
	
	, q( 0,2, [ qn0( gen_line_nothing_here( [ delivery_party(start), 10, 10 ] ) ), delivery_thing_line( [ ( append, delivery_dept ) ] ) ] )
	
	, qn0( gen_line_nothing_here( [ delivery_party(start), 10, 10 ] ) )

	, or( [ [ delivery_street_para( 2, -250, 50 ), set( got_both ) ]
	
		, delivery_street_para( 1, -250, 50 )
		
		, delivery_street_line
		
	] )
	
	, q01( [ qn0( gen_line_nothing_here( [ delivery_party(start), 10, 10 ] ) )
	
		, or( [ [ test( got_both ), delivery_thing_line( [ ( append, delivery_street ) ] ) ]
		
			, [ peek_fails( test( got_both ) ), delivery_thing_line( [ ( delivery_street, s1 ) ] ) ]
			
		] )
	
		, q(0,2, [ qn0( gen_line_nothing_here( [ delivery_party(start), 10, 10 ] ) )
				, delivery_thing_line( [ ( append, delivery_street ) ] ) ]
			)
		
	] )
	
	, qn0( gen_line_nothing_here( [ delivery_party(start), 10, 10 ] ) ), delivery_city_line
	
	, or( [ [ trace( [ `Got postcode?` ] ), peek_fails( test( need_postcode ) ), trace( [ `Yep` ] ) ]
	
		, [ trace( [ `Missing Postcode?` ] ), test( need_postcode ), trace( [ `Yep` ] ), q01( line_on_right ), delivery_postcode_line ]
		
	] )

]).


%=======================================================================
i_line_rule( line_on_right, [ dummy(s1), check( dummy(start) > 0 ) ] ).
%=======================================================================
i_line_rule_cut( delivery_header_line, [ 
%=======================================================================

	q0n(anything)

	, `company`, `:`, q10( tab )
	
	, generic_item( [ delivery_party, s1 ] )

] ).
 
%=======================================================================
i_line_rule_cut( delivery_thing_line( [ Thing ] ), [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, Append_Variable

] ):-

	Thing = ( append, Variable )
	, q_sys_is_atom( Variable )
	, Read_Variable =.. [ Variable, s1 ]
	, Append_Variable =.. [ append, Read_Variable, ` `, `` ]
.
  
%=======================================================================
i_line_rule_cut( delivery_thing_line( [ Thing ] ), [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, generic_item( [ Variable, Parameter ] )

] ):-
	  Thing = ( Variable, Parameter )
	, q_sys_is_atom( Variable )
.
 	
%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, generic_item( [ delivery_city, sf, [ check( delivery_city(y) < -300 ), q10( `,` ) ] ] )
	
	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
	, or( [ [ generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
			, q10( [ `-`, append( delivery_postcode( f( [ begin, q(dec,4,4), end ] ) ), `-`, `` ) ] )
			
		]
		
		, set( need_postcode )
		
	] )	

] ).
 
%=======================================================================
i_line_rule( delivery_street_para, [ 
%=======================================================================
	
	  nearest( delivery_party(start), 10, 10 )
	  
	, read_ahead( [ dummy(d) ] )
	
	, peek_fails( [ dummy(d), `-` ] )
	
	, peek_fails( [ q0n(word), state(f( [ q(alpha,2,2) ] ) ), q0n(word), zip(f( [ q(dec,5,5) ] ) ) ] )
	
	, generic_item( [ delivery_street, sf, `,` ] )
	
	, generic_item( [ delivery_street, s1 ] )

]).


%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, read_ahead( [ or( [ dummy(d), dummy(f( [ begin, q(dec,1,5), q(alpha,1,3), end ] ) ) ] ) ] )
	
	, peek_fails( [ dummy(d), `-` ] )
	
	, peek_fails( [ q0n(word), state(f( [ q(alpha,2,2) ] ) ), q0n(word), zip(f( [ q(dec,5,5) ] ) ) ] )

	, generic_item( [ delivery_street, s1 ] )

] ).
 	
%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, q10( [ `-`, append( delivery_postcode( f( [ begin, q(dec,4,4), end ] ) ), `-`, `` ) ] )
	
]).	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date_1, [ 
%=======================================================================

	q0n(anything)

	, `order`, `date`

	, or( [ invoice_date(date( `m/d/y` ))
	
		, invoice_date(date)
		
	] )

	, newline

	, trace( [ `invoice date`, invoice_date] )

]).

%=======================================================================
i_rule( get_order_date_2, [ 
%=======================================================================

	order_date_2_header_line

	, get_order_date_2_line

]).

%=======================================================================
i_line_rule( order_date_2_header_line, [ 
%=======================================================================

	q0n(anything)

	, `status`

	, trace( [ `invoice date header found` ] )

]).

%=======================================================================
i_line_rule( get_order_date_2_line, [ 
%=======================================================================

	q0n(anything)

	, or( [ invoice_date(date( `m/d/y` ))
	
		, invoice_date(date)
		
	] )

	, newline

	, trace( [ `invoice date`, invoice_date] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `order`

	, order_number(s)

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).

%=======================================================================
i_line_rule( get_revision_number, [ 
%=======================================================================

	q0n(anything)

	, `revision`, `/`, `date`

	, or([ `0`, [ append(order_number(d), `_`, ``), delivery_note_reference(`revision`) ]  ])

	, newline

	, trace( [ `order number`, order_number ] ) 

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	 q0n(anything)

	, `created`, `by`, q01(tab)

	, read_ahead([ dummy(w), buyer_contact(s1) ])

	, or([ [ append(buyer_contact(w), ` ` , ``), `,` ], append(buyer_contact(w), ` ` , ``) ]) 

	, trace([ `buyer contact`, buyer_contact  ])

] ).


%=======================================================================
i_rule( get_buyer_contact_2, [ 
%=======================================================================

	without(buyer_contact)

	, page_number_line

	, q(2,4,up)

	, buyer_contact_line_2


] ).


%=======================================================================
i_line_rule( page_number_line, [ 
%=======================================================================
	
	q0n(anything)

	, `page`, `1`, `of`, num(d), newline
	

] ).


%=======================================================================
i_line_rule( buyer_contact_line_2, [ 
%=======================================================================

	 q0n(anything)

	, read_ahead([ cont(s1), newline ])

	, check(cont(start) > 180)

	, read_ahead([ dummy(w), buyer_contact(s1) ])

	, or([ [ append(buyer_contact(w), ` ` , ``), `,` ], append(buyer_contact(w), ` ` , ``) ]) 

	, trace([ `buyer contact`, buyer_contact  ])

] ).



%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(line) 

	, delivery_contact_header_line

	, get_delivery_contact_line

] ).

%=======================================================================
i_line_rule( delivery_contact_header_line, [ 
%=======================================================================

	`requester`, `contact`, `information`

	, trace([ `delivery contact`, delivery_cotnact  ])

] ).

%=======================================================================
i_line_rule( get_delivery_contact_line, [ 
%=======================================================================

	delivery_contact(sf), `,`, prepend(delivery_contact(sf), ``, ` `)

%	read_ahead([ dummy(w), `,`, delivery_contact(w) ]), append(delivery_contact(w), ` `, ``), `,`, word(w)

	, q10([ `/`

	, or([  [ `(`, delivery_ddi(w), `)`, append(delivery_ddi(s), `-`, ``) ] ,   delivery_ddi(s) ])

	, `,`

	, or([  [ `(`, delivery_fax(w), `)`, append(delivery_fax(s), `-`, ``) ] ,   delivery_fax(s) ]) ])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	`Materials`, `(`, `USD`, `)`, `|`

	, read_ahead(total_net(d))

	, total_invoice(d)

	, trace( [ `total net`, total_net ] )

	, trace( [ `total invoice`, total_invoice ] )

	, newline


] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [
			[ get_invoice_line, q10( [ peek_fails( line_end_line ), extra_item_line ] ) ]
			
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `(`, `USD`, `)`, tab, `(`, `USD`, `)`,  newline ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================


	or([ [`Materials`, `(`, `USD`, `)`, `|`], [`line`, tab, `item`, tab, `supplier`] ])

] ).


%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	generic_item_cut( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_item_for_buyer, w, q10(tab) ] )

	, or( [ [ line_item(w)
	
			, or( [ [ q0n(word), tab ]

				, [ `/`, word ]
				
			] )
		]
		
		, line_item( `Missing` )
	] )
	
	, trace( [ `Line Item`, line_item ] )

	, generic_item_cut( [ line_descr, s, [ q10(tab), generic_item( [ line_original_order_date, date, tab ] ) ] ] )

	, q10( read_ahead( [ parent, line, extra_description_line ] ) )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, append(line_descr(s), ` Masco PO UOM:`, ``), tab

	, append(line_descr(s), ` Masco PO Price:`, ``), tab

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( extra_description_line, [
%=======================================================================

	nearest( -179, 50, 50 )

	, append( line_descr(s), ` `, `` )

] ).

%=======================================================================
i_line_rule_cut( extra_item_line, [
%=======================================================================

	 read_ahead(dummy(w1))

	, check(dummy(start) < -300 )

	, append( line_item_for_buyer(s), ``, `` )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================

	with( invoice, delivery_state, STATE )

	, with( invoice, delivery_city, READ_CITY )

, trace([ `where`, STATE, READ_CITY ])

	, check( i_user_check( lookup_scb, SCB, READ_CITY, STATE ) )

	, suppliers_code_for_buyer( SCB )

	, trace( [ `scfb looked up`, SCB ] )
] ).


%=======================================================================
i_user_check( lookup_scb, SCB, READ_CITY, STATE )
%-----------------------------------------------------------------------
:-
%=======================================================================

 	trace( scfb( TABLE_CITY, STATE ) )

	,  scb_live(  SCB, TABLE_CITY, STATE )   %%%%%%%%%%%%%  CHANGE FOR LIVE %%%%%%%%%%%%%%%%%%%%%

	, string_to_lower( READ_CITY, LOWER_READ_CITY )

	, string_to_lower( TABLE_CITY, LOWER_TABLE_CITY )

	, q_sys_comp( LOWER_READ_CITY = LOWER_TABLE_CITY )

. %end%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCB DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scb_test( `11232115`, `Denver`, `CO`).
scb_test( `11232115`, `Tempe`, `AZ`).
scb_test( `11232115`, `Tucson`, `AZ`).
scb_test( `11232115`, `Dublin`, `CA`).
scb_test( `11232115`, `Fresno`, `CA`).
scb_test( `11232115`, `San Francisco`, `CA`).
scb_test( `11232115`, `W Sacramento`, `CA`).
scb_test( `11232115`, `West Sacramento`, `CA`).
scb_test( `11232115`, `Reno`, `NV`).
scb_test( `11232115`, `Wilsonville`, `OR`).
scb_test( `11232115`, `Pasco`, `WA`).
scb_test( `11232115`, `Sumner`, `WA`).
scb_test( `11232115`, `Vancouver`, `WA`).
scb_test( `11232115`, `Glen Burnie`, `MD`).
scb_test( `11232115`, `Landover`, `MD`).
scb_test( `11232115`, `Jessup`, `MD`).
scb_test( `11232115`, `Hamilton`, `NJ`).
scb_test( `11232115`, `Upper Marlboro`, `MD`).
scb_test( `11232115`, `Manassas`, `VA`).


scb_live( `10763148`, `Denver`, `CO`).
scb_live( `10864336`, `Tempe`, `AZ`).
scb_live( `10864336`, `Tucson`, `AZ`).
scb_live( `10864336`, `Dublin`, `CA`).
scb_live( `10864336`, `Fresno`, `CA`).
scb_live( `10864336`, `San Francisco`, `CA`).
scb_live( `10864336`, `W Sacramento`, `CA`).
scb_live( `10864336`, `West Sacramento`, `CA`).
scb_live( `10864336`, `Reno`, `NV`).
scb_live( `10864336`, `Wilsonville`, `OR`).
scb_live( `10864336`, `Pasco`, `WA`).
scb_live( `10864336`, `Sumner`, `WA`).
scb_live( `10864336`, `Vancouver`, `WA`).
scb_live( `10871872`, `Glen Burnie`, `MD`).
scb_live( `10871872`, `Landover`, `MD`).
scb_live( `10875596`, `Jessup`, `MD`).
scb_live( `10875596`, `Hamilton`, `NJ`).
scb_live( `19151404`, `Upper Marlboro`, `MD`).
scb_live( `19151404`, `Manassas`, `VA`).
