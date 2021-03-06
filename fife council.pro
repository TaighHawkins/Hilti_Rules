%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FIFE COUNCIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fife_council, `22 October 2014` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details
	
	, get_order_number

	, get_invoice_date

	, get_due_date

	, get_buyer_email
	
	, get_buyer_contact

	, get_invoice_lines

	, get_totals
	
] ).

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

	, buyer_registration_number( `GB-FIFECOU` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12308011` )
	
	, delivery_party( `FIFE COUNCIL BUILDING SERVICES` )
	
	, buyer_ddi( `03451555555` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q( 0, 5, line ), generic_horizontal_details( [ [ `Purchase`,`Order`, `Number`, `:` ], order_number, s1, newline ] )
	
	, or( [ [ check( order_number = Order ), check( sys_string_length( order_number, Len ) )

			, check( q_sys_sub_string( Order, Len, 1, `0` ) )
			
		]
		
		, delivery_note_reference( `amended_order` )
		
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q( 0, 10, line ), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date, newline ] ) ] ).
%=======================================================================


%=======================================================================
i_rule( get_due_date, [ q0n( line ), generic_horizontal_details( [ [ `Deliver`, `by`, `:` ], due_date, date, newline ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ q0n(line), buyer_contact_line ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	  `Deliver`, `to`, `:`
	  
	, surname(sf), `,`
	
	, q10( word ), buyer_contact(w), or( [ `(`, newline ] )
	
	, check( surname = Name )
	
	, append( buyer_contact( Name ), ` `, `` )
	
	, trace( [ `buyer contact`, buyer_contact ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q0n(line), delivery_header_line
	  
	, delivery_street_2( `` )
	
	, q(2,1, street_two_line )
	
	, delivery_thing( [ delivery_street, s1 ] )
	
	, check( delivery_street_2 = Street )
	
	, delivery_street( Street )
	
	, delivery_thing( [ delivery_city, s1 ] )
	
	, q10( delivery_thing( [ delivery_state_x, s1 ] ) )
	
	, delivery_thing( [ delivery_postcode, pc ] )
	
] ).


%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), read_ahead( or( [ [ `Ship`, `To`, `:` ], [ `Delivery`, `to` ] ] ) ), hook(s1) ] ).
%=======================================================================
i_line_rule( street_two_line, [ append( delivery_street_2(s1), ``, ` ` ) ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable, Parameter ] ), [
%=======================================================================

	  nearest( hook(start), 10, 10 )
	  
	, Read_Variable
	  
	, newline
	
	, trace( [ String, Variable ] )
	
] ):-

	  Read_Variable =.. [ Variable, Parameter ]
	, sys_string_atom( String, Variable )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PHONE AND FAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Email`, `:` ], buyer_fax, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Net`, `Total`, q10( [ tab, `£` ] ) ], total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Net`, `Total`, q10( [ tab, `£` ] ) ], total_invoice, d, newline ] )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_rule
			
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `No`, `.`, tab, `(` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Net`, `Total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	 
	, line_descr_line
	
	, q10( [ test( no_line_item ), line_item_line ] )
	
	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )

	, clear(no_line_item)

	, qn0( [ line_continuation_line ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )
		
	, `Your`, `item`, `ref`, `:`

	, or( [ generic_item( [ line_item, w, tab ] ), [ set(no_line_item), tab ] ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, or( [ [ line_quantity_uom_code(w), `/` ], line_quantity_uom_code(w) ] ) , q0n(word), tab
	
	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )

	, q10( [ with( invoice, due_date, Date )
	
		, line_original_order_date( Date )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	  or( [ [ test( no_line_item )
	  
			, or( [ [ `item`, `no`, `.`, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
			
					, generic_item( [ line_descr, s1 ] )

					, clear( no_line_item )
					
				]
		  
				, [ line_descr(s), line_item(d) ]
			  
				, [ line_descr(s), line_item( `Missing` ) ]

			] )
		
		]
		
		, [ generic_item( [ line_descr, s1 ] ) ]
		
	] )

	, or([ tab, newline ])

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `Item`, `No`, q10( `:` ), q10( `.` ), generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).


%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  peek_fails( [ `Deliver`, or( [ `to`, `by` ] ) ] )
	  
	, append( line_descr(s1), ` `, `` )
	
	, q01( [ tab, dummy(s1) ] )
	
	, newline

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage` ] )
	, trace( `delivery line, line being ignored` )
.