%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GB HERTEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( gb_hertel, `10 July 2015` ).

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

	, [ q0n(line), generic_horizontal_details( [ [ `Purchase`, `Order`, `No`, newline ] ] ), q(0,2,line), order_number_line ]

	, [ q0n(line), generic_horizontal_details( [ [ `Issue`, `Number`, newline ] ] ), q(0,2,line), issue_number_line ]

	, [ q0n(line), generic_horizontal_details( [ [ `Our`, `Order`, `Date`, newline ] ] ), q(0,2,line), invoice_date_line ]

	, [ q0n(line), generic_horizontal_details( [ [ `Purchase`, `Order`, `No`, newline ] ] ), q(0,6,line), delivery_location_line ]

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

	, buyer_registration_number( `GB-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Hertel (UK) Ltd.` )
	
	, delivery_party( `HERTEL UK LTD` )

	, suppliers_code_for_buyer( `12224616` )
	
	, buyer_ddi( `01642 467652` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( order_number_line, [
%=======================================================================

	q0n(anything)

	, order_number(s1)

	, newline

	, check( order_number(start) > 250 )

	, trace( [ `order_number`, order_number ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_location_line, [
%=======================================================================

	q0n(anything)

	, delivery_location(pc)

	, or( [ tab, newline ] )

	, check( delivery_location(start) > 50 )

	, trace( [ `delivery_location`, delivery_location ] )
	
	, q10( [ check( delivery_location = `CA201PG` )
		, invoice_type( `ZE` )
		, trace( [ `ZE condition triggered` ] )
	] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( issue_number_line, [
%=======================================================================

	q0n(anything)

	, read_ahead( [ dummy(d), check( dummy(start) > 250 ), newline ] )

	, or( [ `1`, [ invoice_type(`ZE`), trace( [ `invoice_type`, invoice_type ] ) ] ] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_date_line, [
%=======================================================================

	q0n(anything)

	, invoice_date(date)

	, newline

	, check( invoice_date(start) > 250 )

	, trace( [ `invoice_date`, invoice_date ] )
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
	  
	, generic_horizontal_details( [ [ `Total`, `Amount`, `(`, `GBP`, `)`, tab ], total_net, d, newline ] )

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

	  , q10( [ line_invoice_rule, q10( extra_description_rule) ] ) 
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Your`, `Part`, `No`, tab, `Our`, `Part`, `No`, tab, `Description` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( extra_description_rule, [ check_for_pack_size, append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	or( [ line_invoice_line_with_your_part_no, line_invoice_line_without_your_part_no ] )

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )

	, count_rule
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_with_your_part_no, [
%=======================================================================

	retab( [ -370, -290, -120, -65, 10, 70, 130, 200, 250, 330, 390 ] )

	, generic_item( [ line_item, d ] )

	, tab

	, q01( [ dummy_our_part_no(s1) ] )

	, tab

	, check_for_pack_size

	, generic_item( [ line_descr, s ] )
	
	, check( line_descr(start) > -300 )
	
	, tab

	, invoice_line_after_description
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_without_your_part_no, [
%=======================================================================

	retab( [ -370, -290, -120, -65, 10, 70, 130, 200, 250, 330, 390 ] )

	, q01( [ dummy_your_part_no(s1) ] )

	, tab

	, q01( [ dummy_our_part_no(s1) ] )

	, tab

	, check_for_pack_size

	, line_descr(s)

	, tab

	, trace( [ `line_item and description`, line_item, line_descr ] )
	
	, invoice_line_after_description
] ).

%=======================================================================
i_rule( invoice_line_after_description, [
%=======================================================================

	q10( dummy_cost(s1) )

	, tab

	, q10( generic_item( [ line_quantity, d ] ) )

	, tab
	
	, generic_item( [ line_quantity_uom_code, s1 ] )

	, tab

	, generic_item( [ line_original_order_date, date ] )

	, tab

	, q01( [ dummy_days(s1) ] )

	, tab

	, generic_item( [ line_unit_amount, d ] )

	, tab

	, qn0( anything )

	, tab

	, generic_item( [ line_net_amount, d ] )
	
	, newline
] ).

%=======================================================================
i_rule_cut( check_for_pack_size, [
%=======================================================================

	q10( read_ahead( [
	
		q0n(anything)
		
		, set( regexp_allow_partial_matching )
		
		, line_pack_size(d)
		
		, `pc`
		
		, clear( regexp_allow_partial_matching )
		
		, trace( [ `line_pack_size`, line_pack_size ] )
	] ) )
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_analyse_line_fields_first( LID ) :- i_analyse_line_pack( LID ).
%=======================================================================
i_analyse_line_fields_first( LID ) :- i_analyse_line_descr_and_item( LID ).
%=======================================================================

%=======================================================================
i_analyse_line_pack( LID )
%----------------------------------------------------------------------
:-
%=======================================================================

	result( _, LID, line_pack_size, Pack )
	
	, result( _, LID, line_quantity, Qty )

	, result( _, LID, line_quantity_uom_code, UOM )

	, trace( [ `checking`, Pack, Qty, UOM ] )

	, string_to_lower( UOM, `lump sum` )

	, sys_calculate_str_multiply( Pack, Qty, New_qty )

	, sys_retractall( result( _, LID, line_quantity, _ ) )

	, assertz_derived_data( LID, line_quantity, New_qty, i_adjusted_for_pack_size )

	, !
.

%=======================================================================
i_analyse_line_descr_and_item( LID )
%----------------------------------------------------------------------
:-
%=======================================================================

	not( result( _, LID, line_item, _ ) )
	
	, result( _, LID, line_descr, Descr )

	, ( q_regexp_match( `^(\\d+)\\D.*`, Descr, Item ) -> true ; q_regexp_match( `.*\\W(\\d+)$`, Descr, Item ) -> true ; q_regexp_match( `.*\\W(\\d+) \\d+[pP][cC].*`, Descr, Item ) -> true )

	, assertz_derived_data( LID, line_item, Item, i_found_item_in_descr )

	, !
.

