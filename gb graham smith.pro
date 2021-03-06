%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GRAHAM SMITH UK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( graham_smith, `20 April 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, check_type

	, get_order_number

	, get_invoice_date

	, get_buyer_email
	
	, get_buyer_contact
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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

	, buyer_registration_number( `GB-GRAHAMS` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `13151733` )
	, delivery_note_number( `13151733` )

	, sender_name( `Graham Smith UK Ltd.` )
	, delivery_party( `GRAHAM SMITH UK LIMITED` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_type, [ q0n(line), line_header_line ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,30,line)
	  
	, or( [ generic_horizontal_details( [ [ `Our`, `Order`, `no`, `:` ], order_number, s1 ] ) 
	
		, generic_vertical_details( [ [ at_start, `Order`, `No`, `.` ], `Order`, end, order_number, s1, [ tab, generic_item( [ invoice_date, date ] ) ] ] )
		
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ without( invoice_date ),
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Date`, `:` ], invoice_date, date ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	buyer_email( From )
	
] )
:-
	i_mail( from, From ),
	not( q_sys_sub_string( From, _, _, `@hilti.com` ) )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	qn0(line)
	
	, or( [ 
		generic_horizontal_details( [ [ at_start, `Buyer`, `:` ], buyer_contact, sf, [ or( [ [ `(`, buyer_ddi(sf), `)` ], tab, `Currency` ] ) ] ] )
		
		, [ generic_vertical_details( [ [ `Buyer`, newline ], buyer_contact_x, sf, or( [ `(`, newline ] ) ] )
			, check( i_user_check( take_first_and_last_name, buyer_contact_x, Names ) )
			, buyer_contact( Names )
		]
		
	] )		
	
] ).

%=======================================================================
i_user_check( take_first_and_last_name, NamesIn, NamesOut )
%=======================================================================
:-
	sys_string_split( NamesIn, ` `, NamesList ),
	NamesList = [ FirstName | _ ],
	sys_reverse( NamesList, [ Surname | _ ] ),
	strcat_list( [ FirstName, ` `, Surname ], NamesOut )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ or( [ [ `PO`, `Total`, `Value`, `:` ], [ at_start, `Net` ] ] ), total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
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
i_line_rule_cut( line_header_line, [ `Line`, tab, `Codes`, `and`, header, set( type_one ) ] ):- not( grammar_set( type_two ) ).
%=======================================================================
i_line_rule_cut( line_header_line, [ `Date`, tab, `Price`, tab, header, set( type_two ) ] ):- not( grammar_set( type_one ) ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Buyer` ]
	
		, [ `Net` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, q10( [ generic_line( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], newline ] ) ] ), set( got_item ) ] )
	
	, line_descr_line  
	
	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_unit_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, clear( got_item )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	  
	, or( [ [ `Our`, `Item`, `:` ]
	
		, [ `Item`, `No`, `:` ]
		
	] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item_cut( [ line_quantity, d ] )

	, generic_item_cut( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item_cut( [ line_original_order_date, date, tab ] )
	
	, generic_item_cut( [ promised, s1, tab ] )

	, generic_item( [ line_unit_amount, d ] )

	, generic_item( [ unit_uom, s1, tab ] )
	
	, generic_item( [ disc, d, [ `%`, tab ] ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ):- grammar_set( type_one ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )

	, generic_item( [ dummy_item, s1, tab ] )
	
	, generic_item_cut( [ line_original_order_date, date, q10( tab ) ] )

	, generic_item_cut( [ line_quantity_uom_code, w, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d ] )

	, generic_item( [ vat, d, [ `%`, newline ] ] )
	
] ):- grammar_set( type_two ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	  or( [ test( got_item )
	  
		, read_ahead( [ q0n(word), `(`, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] )
	  
		, line_item( `Missing` )
		
	] )
	
	, generic_item( [ line_descr, s1, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.