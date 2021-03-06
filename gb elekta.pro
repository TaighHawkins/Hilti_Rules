%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GB ELEKTA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( gb_elekta, `23 June 2015` ).

%	i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ check_for_old_variation_rule ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_old_variation_rule, [ or( [ [ q0n(line), old_header_line ], [ set( new_order ), trace( [ `New variety order` ] ) ] ] ) ] ).
%=======================================================================
i_line_rule( old_header_line, [
%=======================================================================

	`Pos`, q10( tab ), `Item`, `number`, tab, or( [ [ `Item`, `name` ], `Description` ] )
	
	, tab, `Quantity`, q10( tab ), `U`, `/`, `M`

	, set( chain, `elekta` )
	
	, trace( [ `Old variety order` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_fax
	
	, get_delivery_contact
	
	, get_delivery_details

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines

	, get_totals

] ):- grammar_set( new_order ).

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

	, buyer_registration_number( `GB-ELEKTA` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12296512` )

	, delivery_party( `ELEKTA LIMITED` )
	
	, sender_name( `Elekta Limited` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Purchase`, `Order`, `Number` ], `Purchase`, order_number, s1, none ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Order`, `Date` ], `Order`, invoice_date, date, newline ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q0n(line), generic_vertical_details( [ [ `Telephone`, `No`, `.`, newline ], `Telephone`, buyer_ddi, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  q0n(line), generic_vertical_details( [ [ `Telefax`, `No`, `.`, newline ], `Telefax`, buyer_fax, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Our`, `reference`, `:` ], buyer_contact, s1 ] )
	  
	, check( string_string_replace( buyer_contact, ` `, `.`, Con ) )
	
	, check( strcat_list( [ Con, `@elekta.com` ], Email ) )
	
	, buyer_email( Email )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [
%=======================================================================

	  q(0,45,line), generic_horizontal_details( [ [ `This`, `order`, `has`, `been`, `approved`, `by`, `:` ], delivery_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Delivery`, `Address`, `:` ], delivery_hook, s1 ] )
	  
	, check( delivery_hook(start) = Left )

	, q(0,8,line), generic_line( 2, Left, -40, [ [ q0n(word), some_postcode(pc) ] ] )
	
	, or( [ [ check( some_postcode = `RH109QB` ), delivery_note_number( `22098038` ) ]
	
		, [ check( some_postcode = `RH109RR` ), delivery_note_number( `21668329` ) ]
		
	] )

] ).

%=======================================================================
ii_rule( get_delivery_details, [
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Delivery`, `Address`, `:` ], delivery_hook, s1 ] )
	  
	, check( delivery_hook(start) = Left_x )
	
	, check( sys_calculate( Left, Left_x - 10 ) )
	
	, peek_ahead( gen_count_lines( [ line_addr_end_line, Count ] ) )
	
	, get_delivery_address_line( Count, Left, -50 )

] ).

%=======================================================================
i_line_rule( line_addr_end_line, [ or( [ [ `United`, `Kingdom` ], [ `Delivery`, `way`, `:` ] ] ) ] ).
%=======================================================================
i_line_rule( get_delivery_address_line, [
%=======================================================================

	  generic_item( [ street_2, sf, `,` ] )
	  
	, generic_item( [ delivery_street, sf, generic_item( [ delivery_city, w, `,` ] ) ] )
	
	, check( street_2 = Str )
	
	, delivery_street( Str )
	
	, generic_item( [ delivery_district, sf, q10( `,` ) ] )
	
	, generic_item( [ delivery_postcode, pc ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  last_line, q(0,20,up), generic_horizontal_details( [ [ `Sum` ], 200, total_net, d, newline ] )
	  
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
i_line_rule_cut( line_header_line, [ `Article`, `number` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ `Sum`, [ `Organisation`, `number` ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  read_ahead( line_invoice_line )
	  
	, gen1_parse_text_rule( [ -500, -50, or( [ line_end_line, line_check_line ] ) ] )
	
	, check( captured_text = Descr )

	, line_descr( Descr )

	, q10( [ check( i_user_check( check_for_delivery, Descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), some(date) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  or( [
	  
		generic_item_cut( [ line_item, [ begin, q(dec,3,10), end ], tab ] )
	  
		, [ dum(d), tab, q10( `ITEM` ), generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ] ] ) ]
		
		, [ dum(d), tab, line_item( `Missing` ) ]
		
	] )

	, or( [ generic_item_cut( [ dummy_descr, s1, tab ] ), tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_net_amount, d, tab ] )
	
	, generic_item_cut( [ line_original_order_date, date, newline ] )
	
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

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).