%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CA VALE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ca_vale, `02 March 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( invoice, buyer_location, `Buyer Location` ).

i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
e1edkt1_tdformat_value( `Z012`, `/` ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).
i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
e1edkt1_tdformat_value( `Z011`, `/` ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
e1edkt1_tdformat_value( `0012`, `/` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_date
	
	, get_order_number
	
	, get_contact_information
	
	, get_shipping_information

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `01` )
	, cost_centre( `Standard` )

	, sender_name( `Vale Canada Ltd.` )
	
	, or( [ [ test( test_flag )
			, suppliers_code_for_buyer( `11262797` )
			, delivery_note_number( `11262797` )
			, buyer_location( `2076105` )
			, delivery_from_location( `2076105` )
		]
		
		, [ suppliers_code_for_buyer( `10687228` )
			, delivery_note_number( `20660465` )
			, buyer_location( `16446168` )
			, delivery_from_location( `16446168` )
		]
	] )
	
	, set( no_uom_transform )
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT INFORMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_information, [
%=======================================================================

	q(0,30,line)
	
	, generic_horizontal_details( [ [ `Contact`, `Information` ] ] )
	
	, q10( [ q(0,5,line), generic_horizontal_details( [ [ `Buyer`, `:` ], buyer_contact_x, s1 ] )
		, check( strip_string2_from_string1( buyer_contact_x, `,`, ConString ) )
		, check( sys_string_split( ConString, ` `, ConList ) )
		, check( sys_reverse( ConList, ConReversed ) )
		, check( wordcat( ConReversed, Con ) )
		, buyer_contact( Con )
		, delivery_contact( Con )
	] )
	
	, q10( [ q(0,5,line), generic_horizontal_details( [ [ `Phone`, `:` ], buyer_ddi, s1 ] )
		, check( buyer_ddi = DDI )
		, delivery_ddi( DDI )
	] )

	, q10( [ q(0,5,line), generic_horizontal_details( [ [ `E`, `-`, `mail`, `:` ], buyer_email, s1 ] )
		, check( buyer_email = Email )
		, delivery_email( Email )
	] )
	
	, q10( [ with( buyer_email ), with( buyer_contact )
		, remove( buyer_location )
		, remove( delivery_from_location )
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INFORMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_information, [
%=======================================================================

	packing_instructions( `VALE SHIPPING INSTRUCTIONS~ ~AS PER CUSTOMERS REQUEST PLEASE LABEL IN BLACK MARKER~• THE P.O. NUMBER~• THE NUMBER OF BOXES ON ORDER~ ~FOR EXAMPLE~ ~P.O. 00000~1 OF 2 / 2 OF 2 ETC` )
	
	, check( packing_instructions = Pack )
	, picking_instructions( Pack )
	, shipping_instructions( Pack )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Date`, q10( tab ), `:` ], invoice_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,3,line)
	
	, generic_vertical_details( [ [ `PURCHASE`, `ORDER` ], `PURCHASE`, end, order_number, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_lines, [
%=======================================================================

	line_header_line

	, line_values_line
	
	, q0n( or( [ line_material_to_expense_line, line_continuation_line, line ] ) )
	
	, or( [ line_item_line
	
		, [ generic_line( [ [ `Delivery`, `Schedule` ] ] ), line_item( `Missing` ) ]
		
	] )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Item`, tab, `Qty`, tab, `UOM` ] ).
%=======================================================================
i_line_rule_cut( line_date_line, [ q0n(anything), dummy(f( [ q(dec,2,2) ] ) ), `-`, dumm( f( [ q(alpha,3,3) ] ) ), `-`, dum(f( [ q(dec,4,4) ] ) ) ] ).
%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================
   
	generic_item( [ line_no, d, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code_x, w, q10( tab ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, set( allow_continuation )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ test( allow_continuation ), append( line_descr(s1), ` `, `` ), or( [ newline, [ tab, `HST` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_material_to_expense_line, [ `Material`, `to`, clear( allow_continuation ) ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
   
	`Supplier`, `Part`, `Number`, `:`
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ at_start, `Purchase`, `Order`, `Total`, dummy(s1), tab, `CAD` ], total_net, d ] )
	, check( total_net = Net )
	, total_invoice( Net )
	
] ).


%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).