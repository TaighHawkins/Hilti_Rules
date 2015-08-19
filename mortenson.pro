%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MORTENSON CONSTRUCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( mortenson_construction, `20 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

i_op_param( o_mail_subject, _, _, _, Subject )
:-
	data( invoice, delivery_note_reference, `special_rule` ),
	Subject = `US-ADAPTRI eB2B mortenson rejected by rule - revision`
.
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	check_for_revision
	
	, get_fixed_variables

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[ q0n(line), get_invoice_totals]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FOR REVISION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_revision, [ 
%=======================================================================

	q(0,20,line)
	
	, generic_vertical_details( [ [ `Revision`, `No` ], `No`, start, 40, 5, revision, d ] )
	
	, check( q_sys_comp_str_gt( revision, `0` ) )
	, delivery_note_reference( `special_rule` )
	, trace( [ `Revision rule triggered - document NOT processed` ] )
	, set( do_not_process )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_customer_comments

	, get_shipping_instructions

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_ddi ]

	,[q0n(line), get_delivery_email ]

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	 buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)


	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10478686` ) ]  %TEST
		, suppliers_code_for_buyer( `10776472` )	%PROD
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	q0n(line)

	, customer_comments_attn

	, q(0,2,line)

	, customer_comments_phone

	, q(0,2,line)

	, customer_comments_fax

]).

%=======================================================================
i_line_rule( customer_comments_attn, [ 
%=======================================================================

 	  q0n(anything)

  	, `ATTN`, `:`

 	, customer_comments(`ATTN:`)

	, read_ahead(dumm(w))

 	, check(dumm(start) > -20 )

	, check(dumm(end) < 200 )

	, append(customer_comments(s), ` `, ``)

	, trace( [ `customer_comments header found` ] )

]).



%=======================================================================
i_line_rule( customer_comments_phone, [ 
%=======================================================================

   q0n(anything)

   , `Phone`, `:`

  , append(customer_comments(`- Phone:`), ` `, ``)

  , q10([  read_ahead(dummyphone(w) )

  , check(dummyphone(start) > -20 )

 , check(dummyphone(end) < 200 )
 
 , append(customer_comments(s1), `-`, ``)  ])

]).





%=======================================================================
i_line_rule( customer_comments_fax, [ 
%=======================================================================

   q0n(anything)

   , `fax`, `:`, q10(tab)

  , append(customer_comments(` - Fax:`), ` `, ``)

  , q10([  read_ahead(dummyfax(w) )

  , check(dummyfax(start) > -20 )

 , check(dummyfax(end) < 200 )
 
 , append(customer_comments(s1), `-`, ``)  ])

]).

%=======================================================================
i_line_rule(customer_comments_fax_line, [ 
%=======================================================================

	 q0n(anything)

	, read_ahead(faxnum(s))

	, check(faxnum(start) > -20 )

	, check(faxnum(end) < 200 )

	 , append(customer_comments(s), ` `, ``)

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	q0n(line)

	, shipping_instructions_attn

	, q(0,2,line)

	, shipping_instructions_phone

	, q(0,2,line)

	, shipping_instructions_fax


]).


%=======================================================================
i_line_rule( shipping_instructions_attn, [ 
%=======================================================================

 	  q0n(anything)

  	, `ATTN`, `:`

 	, shipping_instructions(`ATTN:`)

	, read_ahead(dummm(w))

 	, check(dummm(start) > -20 )

	, check(dummm(end) < 200 )

	, append(shipping_instructions(s), ` `, ``)

	, trace( [ `shipping_instructions header found` ] )

]).



%=======================================================================
i_line_rule( shipping_instructions_phone, [ 
%=======================================================================

   q0n(anything)

   , `Phone`, `:`

  , append(shipping_instructions(`- Phone:`), ` `, ``)

  , q10([  read_ahead(dummmyphone(w) )

  , check(dummmyphone(start) > -20 )

 , check(dummmyphone(end) < 200 )
 
 , append(shipping_instructions(s1), ` `, ``)  ])

]).





%=======================================================================
i_line_rule( shipping_instructions_fax, [ 
%=======================================================================

   q0n(anything)

   , `fax`, `:`, q10(tab)

  , append(shipping_instructions(` - Fax:`), ``, ``)

  , q10([  read_ahead(dummmyfax(w) )

  , check(dummmyfax(start) > -20 )

 , check(dummmyfax(end) < 200 )
 
 , append(shipping_instructions(s1), ` `, ``)  ])

]).

%=======================================================================
i_line_rule(shipping_instructions_fax_line, [ 
%=======================================================================

	 q0n(anything)

	, read_ahead(faxnum(s))

	, check(faxnum(start) > -20 )

	, check(faxnum(end) < 200 )

	 , append(shipping_instructions(s), ` `, ``)

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  delivery_street(``)

	, delivery_header_line

	 , delivery_party_line( 1, -10, 200 )

	 , q(0,4,delivery_party_append_line( 1, -10, 200 ))

	, q10( first_street )

	 , q( 1, 2, delivery_street_line( 1, -10, 200 ) )

	 , delivery_city_line( 1, -10, 200 )

]).


%=======================================================================
i_rule( first_street, [ 
%=======================================================================
	
	read_ahead( dum(d) ), first_street_line( 1, -10, 200 ), set( got_first )

	, peek_fails(delivery_city_line( 1, -10, 200 ) )

]).

%=======================================================================
i_line_rule( first_street_line, [ 
%=======================================================================
	
	  append(delivery_street(s1), ` `, ``)

	%, check(delivery_street(start) > -10 )

	%, check(delivery_street(end) < 200 )

	, trace([ `delivery street from first street`, delivery_street ]) 

]).

 	
%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	
	q0n(anything)

	, `ship`, `to`, `:`

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	  delivery_party(s1)

	, trace([ `delivery party`, delivery_party ]) 

	
]).

%=======================================================================
i_line_rule( delivery_party_append_line, [ 
%=======================================================================


	  peek_fails( [ q0n(word), or( [ `Street`, `St` ] ) ] )
	  
	, append(delivery_party(s1), ` `, ``)

	, q10([ tab, append(delivery_street(w), ` `, ``) ])

	, trace([ `delivery party`, delivery_party ]) 

	
]).


%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	  or( [ [ peek_fails( test( got_first ) ), read_ahead( num(d) ), set( got_first ) ]
	  
		, test( got_first )
		
	] ), append(delivery_street(s1), ` `, ``)
	  
	, q10( [ tab, append( delivery_street(s1), ` `, `` ) ] )

	%, check(delivery_street(start) > -10 )

	%, check(delivery_street(end) < 200 )

	, trace([ `delivery street from other street`, delivery_street ]) 

]).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================

	 delivery_city(sf)
	 
	, `,`
	
	, trace([ `delivery city`, delivery_city ]) 

	, delivery_state(w)

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ]) 
	
]).	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	order_date_header_line

	, get_order_date_line	

]).

%=======================================================================
i_line_rule( order_date_header_line, [ 
%=======================================================================

	`date`, `:`, tab

	, trace( [ `invoice date header found` ] )

]).

%=======================================================================
i_line_rule( get_order_date_line, [ 
%=======================================================================

	invoice_date(date)

	, check(invoice_date(end) < -290 )

	, trace( [ `invoice date`, invoice_date] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	order_number_header

	, get_order_number_line

] ).

%=======================================================================
i_line_rule( order_number_header, [ 
%=======================================================================

	`PURCHASE`, `ORDER`, `NO`, `:`

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	order_number(s)

	, check(order_number(end) < 170 )

	, trace( [ `order number`, order_number ] )

	, q10([ tab, append(order_number(d), `_`,``), or([tab, newline ]) ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`buyer`, `:`, tab

	, buyer_contact(s)

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`buyer`, `phone`, `:`, tab

	, buyer_ddi(s)

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	`buyer`, `e`, `-`, `mail`, `:`, tab

	, buyer_email(s)

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	`requestor`, `:`, tab

	, read_ahead([ surname(w), delivery_contact(s) ])

%	% , or([ [delivery_contact(w), `,`], delivery_contact(w) ])
	
	, trace( [ `del cont`, delivery_contact ] )

	, or([ [ append(delivery_contact(w), ` `, ``), `,` ], append(delivery_contact(w), ` `, ``) ])

	, trace( [ `del cont`, delivery_contact ] )

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	`resquestor`, `phone`, `:`, tab

	, delivery_ddi(s)

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	`requestor`, `e`, `-`, `mail`, `:`, tab

	, delivery_email(s)

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

	`Total`, `(`, `Before`, `Tax`, `)`, `:`, tab

	, read_ahead(total_net(d))

	, total_invoice(d)

	, newline

	, trace( [ `total net`, total_net ] )

	, trace( [ `total invoice`, total_invoice ] )

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

		, or([ get_invoice_line, line_continuation_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `CURRENCY`, `:`, `USD`,  newline ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	read_ahead([dummy(s1), newline ])

	, check(dummy(start) > -215)

	, check(dummy(end) < 80)

	, append(line_descr(s1), ` `, ``)

	, newline


] ).


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================


	or([ [`Total`, `(`, `Before`, `Tax`, `)`, `:`, tab], [`standard`, `purchase`, `order` ] ])

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	  get_line_invoice_line

	, or( [ get_item_and_descr_line
	
		, [ or( [ get_item_line, set( missing_item ) ] )

			, get_descr_line
			
			, or( [ peek_fails( test( missing_item ) )
			
				, [ test( missing_item )
				
					, or( [ [ q0n( trash_line), mfg_product_line, get_item_line ]
					
						, line_item( `Missing` )
						
					] )
					
				]
				
			] )
			
		]

	] )
	
	, clear( missing_item )
	
] ).

%=======================================================================
i_line_rule_cut( get_line_invoice_line, [
%=======================================================================

	line_order_line_number(d), tab

	, line_quantity(d), tab

	, trace([`line quantity`, line_quantity])

	, uomcode(w), tab

	, trace([`line quantity uom code`, line_quantity_uom_code])

	, linedescr(s), tab

	, line_unit_amount(d), tab

	, trace([`line unit amount`, line_unit_amount])

	, line_net_amount(d), tab

	, trace([`line net amount`, line_net_amount])

	, tax(w), tab

	, line_original_order_date(date)

	, trace([`line original order date`, line_original_order_date])

	, newline


] ).

%=======================================================================
i_line_rule( mfg_product_line, [ `Mfg`, `product` ] ).
%=======================================================================
i_line_rule( get_item_line, [
%=======================================================================

	 or( [ [ line_item( f([begin, q(dec,3,9), end ]) )

			, check(line_item(end) < 220 )
			
		]
		
		, [ peek_fails( test( missing_item ) ), `Item`, `No`, `-`
			
			, line_item( f( [ begin, q(dec,3,10), end ] ) )
			
		]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( get_descr_line, [
%=======================================================================

	line_descr(s)

	, trace([`line descr`, line_descr])

	, check(line_descr(end) < 220 )

] ).

%=======================================================================
i_line_rule_cut( get_item_and_descr_line, [
%=======================================================================

	  generic_item( [ line_item, [ begin, q(dec,4,10), end ], q10( `:` ) ] )
	  
	, generic_item( [ line_descr, s1 ] )

] ).

%=======================================================================
i_line_rule_cut( trash_line, [ generic_item( [ trash, s1, newline ] ) ] ).
%=======================================================================

