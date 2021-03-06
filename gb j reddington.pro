%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - J REDDINGTON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( j_reddington, `06 July 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_due_date
	
	, check_invoice_type

	, get_delivery_details
	
	, get_buyer_email
	
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

	, buyer_registration_number( `GB-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12298884` )

	, sender_name( `J Reddington Ltd.` )
	, delivery_party( `J Reddington Ltd.` )
	
	, buyer_ddi( `02083274064` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,30,line)
	  
	, or( [ [ check( q_sys_sub_string( Attach, _, _, `.htm` ) )
			, generic_vertical_details( [ `Number`, `Number`, q(0,0), start, order_number, s1, newline ] ) 
		]
		
		, generic_horizontal_details( [ [ or( [ tab, at_start ] ), `Number` ], 400, order_number, s1 ] ) 
	] )
	
	
] ):- i_mail( attachment, Attach ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,30,line)
	  
	, or( [ generic_horizontal_details( [ [ or( [ tab, at_start ] ), `Date` ], 400, invoice_date, date ] )
	
		, generic_line( [ generic_item( [ invoice_date, date ] ) ] )
		
	] )
 
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,30,line)
	  
	, or( [ generic_horizontal_details( [ [ or( [ tab, at_start ] ), `Due`, `Date` ], 400, due_date, date ] )
	
		, generic_vertical_details( [ [ `Due`, `Date` ], due_date, date ] )
		
	] )
 
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_invoice_type, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `Amended`, `Purchase`, `Order` ] ] )
	
	, invoice_type( `ZE` )
	, trace( [ `ZE condition triggered` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	buyer_email( From ),
	buyer_contact( Con )
	
] )
:- 
	i_mail( from, From ), string_to_lower( From, FromL ),
	not( q_sys_sub_string( FromL, _, _, `@hilti` ) ),
	
	sys_string_split( From, `@`, [ NameDot | _ ] ),
	string_string_replace( NameDot, `.`, ` `, Con )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q0n(line)
	
	, or( [ generic_horizontal_details( [ [ `Internal`, `Ref`, tab ], delivery_location_raw, s1 ] )
	
		, generic_vertical_details( [ [ `Internal`, `Ref` ], delivery_location_raw, s1 ] )
	] )
	
	, check( sys_string_split( delivery_location_raw, `/`, [ _, Location ] ) )
	, delivery_location( Location )
	, trace( [ `Delivery Location`, Location ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  qn0(line)
	  
	, generic_line( 2, [ [ `Nett`, q10( tab ), generic_item( [ total_net, d ] ) ] ] )

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
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	or( [ [ q0n(anything), read_ahead( `Quantity` ), qty_hook(w)
			, q0n(anything), read_ahead( `Description` ), descr_hook(w)
			, q0n(anything), read_ahead( `Price` ), price_hook(w)
		]
		
		, [ `Code`, newline, set( type_two ) ]
	] )
	
] ).


%=======================================================================
i_line_rule_cut( line_end_line, [ `Delivery` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  or( [ [ peek_fails( test( type_two ) ) , line_invoice_line ]
	  
		, [ test( type_two )
			, generic_line( [ generic_item( [ line_order_line_number, d, newline ] ) ] )
			, generic_line( [ generic_item( [ line_quantity, d, newline ] ) ] )
			, generic_line( [ generic_item( [ line_quantity_uom_code, s1, newline ] ) ] )
			, generic_line( [ [
				or( [ read_ahead( [ q0n(word), line_item( f( [ begin, q(dec,4,10), end ] ) ) ] )
					, line_item( `Missing` )
				] )
					, generic_item( [ line_descr, s1, newline ] ) 
			] ] )
			, generic_line( [ generic_item( [ line_unit_amount, d, newline ] ) ] )
			, generic_line( [ generic_item( [ vat, d, newline ] ) ] )
			, generic_line( [ generic_item( [ line_net_amount, s1, newline ] ) ] )
		]
		
	] )
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )
	
	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_unit_amount = Net )

		, delivery_charge( Net )
	
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  check( qty_hook(start) = QtyHookRaw )
	, check( sys_calculate( QtyHookStart, QtyHookRaw - 10 ) )
	
	, check( qty_hook(end) = QtyHookEnd )
	, check( descr_hook(start) = DescrHook )
	, check( price_hook(start) = PriceHookStart )
	, check( price_hook(end) = PriceHookEnd )

	, retab( [ QtyHookStart, QtyHookEnd, DescrHook, PriceHookStart, PriceHookEnd ] )
	
	, generic_item_cut( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ vat_code, d ] )	
	, generic_item( [ line_net_amount, d, newline ] )

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