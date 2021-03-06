%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SELECT PLANT HIRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( select_plant_hire, `03 July 2015` ).

%i_pdf_parameter( same_line, 6 ).
i_pdf_parameter( max_pages, 5 ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).

i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_due_date

	, get_delivery_details
	
	, get_delivery_details_alternate
	
	, get_buyer_email
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_picking_instructions
	
	, get_packing_instructions
	
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

	, buyer_registration_number( `GB-SELECTP` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12270568` )
	
	, delivery_party( `SELECT PLANT HIRE COMPANY LIMITED` )

	, sender_name( `SELECT PLANT HIRE COMPANY LIMITED` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,10,line)
	  
	, generic_horizontal_details( [ [ `ORDER`, `No`, `:`, tab, retab( [ -500 ] ) ], order_number_x, s1 ] )

	, or( [ [ check( i_user_check( validate_order_number, order_number_x, Order ) )
	
			, order_number( Order )
			
		] 
	
		, [ delivery_note_reference( `amended_order` ), invoice_type( `ZE` ) ]
	
	] )
	
] ).

%=======================================================================
i_user_check( validate_order_number, Order, Ord ):-
%=======================================================================

	sys_string_length( Order, Len )		
	, q_sys_sub_string( Order, Len, 1, Valid )
	
	, ( Valid = `1`	->	 Order = Ord
	
		;	Valid = `/`
			, sys_calculate( Len_Min_One, Len - 1 )
			, q_sys_sub_string( Order, 1, Len_Min_One, Ord )
			
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date ] ) 
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Delivery`, `Date`, `:` ], invoice_date, date ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_type_of_supply, [ q(0,15,line), generic_horizontal_details( [ [ `Delivery`, `Type`, `:` ], type_of_supply, w ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ q(0,25,line), generic_horizontal_details( [ [ `Buyer`, `Email`, `:` ], buyer_email, s1 ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( get_buyer_contact, [ q(0,25,line), generic_horizontal_details( [ [ `Buyer`, `Name`, `:` ], buyer_contact, s1 ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( get_buyer_ddi, [ q(0,25,line), generic_horizontal_details( [ [ `Buyer`, `Tel`, `No`, `:` ], buyer_ddi, s1 ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Delivery`, `address`, `:`, tab, peek_fails( `0` ) ], delivery_note_number, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_details_alternate, [
%=======================================================================

	  without( delivery_note_number )
	  
	, q(0,25,line), generic_horizontal_details( [ [ `Address`, `1`, q0n(word), `>` ], delivery_street, s1 ] )
	
	, q01(line), generic_horizontal_details( [ [ `Address`, `2`, q0n(word), `>` ], delivery_street, s1 ] )
	
	, q01(line), generic_horizontal_details( [ [ `City`, q0n(word), `>` ], delivery_city, s1 ] )
	
	, q01(line), generic_horizontal_details( [ [ `Postal`, `Code`, q0n(word), `>` ], delivery_postcode, pc ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_packing_instructions, [ with( invoice, picking_instructions, Pick ), packing_instructions( Pick ) ] ).
%=======================================================================
i_rule( get_picking_instructions, [
%=======================================================================

	  picking_instructions( `Please Engrave with:` )
	  
	, q(0,50,line), line_picking_header_line
	
	, trace( [ `Found header` ] )
	
	, peek_fails( [ q0n( gen_line_nothing_here( [ fleet_hook(end), 20, 10 ] ) ), line_end_line ] )
	
	, q0n( or( [ append_picking_line, line ] ) )
	
	, or( [ generic_horizontal_details( [ read_ahead( [ `Engraving`, `Services` ] ), dummy, s1 ] )
	
		, line_end_line
		
	] )

] ).

%=======================================================================
i_line_rule( line_picking_header_line, [ `Commodity`, q0n(anything), tab, read_ahead( `Fleet` ), fleet_hook(w) ] ).
%=======================================================================
i_line_rule( append_picking_line, [
%=======================================================================

	  nearest( fleet_hook(end), 20, 10 )

	, append( picking_instructions(s1)
	, `
	`, `` )	%	To add a return between each line
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q(0,100,line), q10( generic_horizontal_details( [ [ `Carriage` ], 150, delivery_charge, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Order`, `Total` ], 150, total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [ [ or( [ with( invoice, delivery_charge, Charge )
				, check( delivery_charge = Charge )
			] )
	
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
i_line_rule_cut( line_header_line, [ `Ordered`, tab, `Excluding` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Carriage` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_quantity, d, tab ] )
	
	, generic_item_cut( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], q10( tab ) ] )
	
	, generic_item_cut( [ line_descr, s1 ] )
	
	, or( [ newline
	
		, [ tab
		
			, q10( generic_item_cut( [ fleet, s1, tab ] ) )
		
			, generic_item_cut( [ line_unit_amount, d, tab ] )
			
			, generic_item_cut( [ some_uom, s1, tab ] )
			
			, generic_item_cut( [ some_num, d, tab ] )
			
			, generic_item_cut( [ line_net_amount, d, newline ] )
			
		]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).