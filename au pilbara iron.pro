%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PILBARA IRON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( pilbara_iron, `24 September 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
		
	, get_order_number
	
	, get_order_date
	
	, get_delivery_address
	
	, get_delivery_note_reference
	
	, get_shipping_instructions
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_fax
	
	, get_buyer_email
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `AU-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10493821` ) ]
		, suppliers_code_for_buyer( `11172462` )
	] )

	, sender_name( `Pilbara Iron Company (Services) Pty Ltd.` )
	, delivery_party( `Pilbara Iron Company Pty Ltd` )
	
	, set( delivery_note_ref_no_failure )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE REFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_reference, [ 
%=======================================================================

	  q(0,30,line), generic_line( 1, -200, 100, [ [ q0n(anything), `To`, `:`, tab, generic_item( [ ref, s1 ] ) ] ] )
	  
	, check( i_user_check( turn_ref_into_dnr, ref, DNR ) )
	
	, delivery_note_reference( DNR )
	
] ).

%=======================================================================
i_user_check( turn_ref_into_dnr, Ref, DNR )
%-----------------------------------------------------------------------
:- 
%=======================================================================
	strip_string2_from_string1( Ref, ` /`, Ref_Strip ),
	string_to_upper( Ref_Strip, Ref_U ),
	sys_string_length( Ref_U, Len ),
	
	( Len =< 14
		->	Ref_U = Ref_End
		
		;	q_sys_sub_string( Ref_U, 1, 14, Ref_End )
	),
	
	strcat_list( [ `AU`, Ref_End ], DNR )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	  q(0,30,line), read_ahead( generic_line( 1, -100, 100, [ [ `Marking`, `Instructions` ] ] ) )
	  
	, q0n( 
		or( [ shipping_instructions_line( 1, -130, 120 )
		
			, line
		] )
	)
	
	, test( final_ship )
	
] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [ 
%=======================================================================

	  retab( [ 500 ] )
	  
	, q10( [ read_ahead( `From` ), set( final_ship ) ] )
	
	, or( [ [ without( shipping_instructions )
	
			, generic_item( [ shipping_instructions, s1 ] )
			
		]
		
		, [ with( shipping_instructions )
		
			, append( shipping_instructions(s1), `
`, `` )
		
		]
		
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_thing( [ Var, Par ] ), [ nearest( generic_hook(start), 10, 10 ), generic_item( [ Var, Par ] ) ] ).
%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `delivery`, `To`, `:` ] ] )
	  
	, line
	
	, q10( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
	, delivery_thing( [ delivery_dept, s1 ] )
	
	, q10( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
	, delivery_thing( [ delivery_address_line, s1 ] )

	, q10( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
	, delivery_street_and_more_line(2)
	
] ).

%=======================================================================
i_line_rule( delivery_street_and_more_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	  
	, generic_item( [ delivery_street, sf, `,` ] )
	
	, generic_item( [ delivery_city, sf, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] ) ] )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Purchase`, `Order`, `Number` ], `Purchase`, end, order_number, s1 ] ) 
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `For`, `Queries`, `:` ], buyer_contact, s1 ] )

	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Phone`, `:` ], buyer_ddi, s1 ] )

	, check( buyer_ddi = DDI )
	
	, delivery_ddi( DDI )
	
] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Fax`, `:` ], buyer_fax, s1 ] )

	, check( buyer_fax = Fax )
	
	, delivery_fax( Fax )
	
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,30,line)
	  
	, or( [ generic_horizontal_details( [ [ `Email`, `:` ], buyer_email, s1 ] )
	
		, generic_horizontal_details( [ [ or( [ at_start, tab ] ), read_ahead( [ q0n(word), `@` ] ) ], buyer_email, s1 ] )
		
	] )
	
	, check( buyer_email(start) > 140 )

	, check( buyer_email = Email )
	
	, delivery_email( Email )
	
] ).

%=======================================================================
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  q0n(word), `Tax`, `Exclusive` , tab
	  
	, read_ahead( [ generic_item( [ total_net, d ] ) ] )
	
	, generic_item( [ total_invoice, d ] )
	
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `*`, `Please`, `ensure` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_invoice_rule
		
			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Description`, `/`, `Your` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total`, `Order` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, q0n( line_continuation_line )
	
	, line_item_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, [ q10( tab ), some(date), newline ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ read_ahead( generic_item( [ dummy, s1 ] ) ), append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ 
%=======================================================================

	`Your`, `Material`, `Number`, `:`
	
	, generic_item( [ line_item, s1, newline ] )
	
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