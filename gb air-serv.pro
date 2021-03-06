%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AIR-SERV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( air_serv, `25 February 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).
i_user_field( invoice, type_of_supply, `Type of Supply` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [ `Purchase`, `Order`, `No`, `.` ], order_number, s1, [ tab, `Date` ] ] )
	, gen_capture( [ [ `Date`, `of`, `order`, `:` ], invoice_date, date, newline ] )
	
	, gen_capture( [ [ `Date`, `of`, `order`, `:` ], type_of_supply, date, newline ] )

	, get_buyer_contact_and_email

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

	, buyer_registration_number( `GB-AIRSERV` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `AIR-serv (Airvending Ltd.)` )
	
	, delivery_party( `AIR VENDING LTD T/A AIR SERV` )
	, delivery_note_number( `12241017` )
	
	, suppliers_code_for_buyer( `12241017` )
	
	, buyer_ddi( `01942 722 333` )
	, buyer_fax( `01942 407 247` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT AND EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact_and_email, [
%=======================================================================

	  buyer_email(From), trace( [ `buyer_email`, buyer_email ] )
	
	, buyer_contact(Contact), trace( [ `buyer_contact`, buyer_contact ] )
	
] )
:-
	i_mail( from, From ),
	sys_string_split( From, `@`, [ Name, Domain ] ),
	string_to_upper( Domain, DOMAIN ),
	DOMAIN \= `HILTI.COM`,
	string_string_replace( Name, `.`, ` `, Contact )
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
	  
	, generic_horizontal_details( [ [ `Nett`, `Goods`, `Value` ], 200, total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [
	
		[ with( invoice, delivery_charge, Charge )
	
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, q0n( or( [ line_invoice_rule, line ] ) )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	  `product`, `code`, tab, `product`, `code`, tab, `Description`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `*`, `*`, `*`, `*`, `*`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )

	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ air_serv_code, s1, tab ] )
	
	, generic_item( [ line_item, s1, tab ] )
	
	, q10( [ read_ahead( [ q0n(word), or( [ `collect`, `collected`, `collecting` ] ) ] )
	
		, read_ahead( generic_item( [ invoice_type, s1 ] ) )
	
	] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, `£`, generic_no( [ line_unit_amount, d, tab ] )
	
	, `£`, generic_no( [ line_net_amount, d, tab ] )
	
	, generic_item( [ deliver_on, date, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
	, trace( [ `line_order_line_number`, line_order_line_number ] )

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, string_string_replace( Delivery_L, `/`, ` / `, Delivery_Rep )
	, sys_string_split( Delivery_Rep, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.