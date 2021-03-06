%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BHP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( bhp, `22 May 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_vert_capture( [ [ `Purchase`, `Order`, gen_eof ], `Purchase`, q(0,2), start, order_number, s1 ] )
	, gen_capture( [ [ gen_beof, `Date`, `:` ], invoice_date, date, newline ] )
	
	, get_buyers_code_for_buyer_and_delivery_note_reference
	
	, gen_capture( [ [ `BHP`, `Billiton`, `Contact`, `:` ], buyer_contact, s1, newline ] )
	, gen_capture( [ [ `BHP`, `Billiton`, `Contact`, `:` ], delivery_contact, s1, newline ] )
	
	, gen_capture( [ [ gen_beof, `Telephone`, `:` ], buyer_ddi, s1, [ check( buyer_ddi(start) > 100 ), newline ] ] )
	, gen_capture( [ [ gen_beof, `Facsimile`, `:` ], buyer_fax, s1, [ check( buyer_fax(start) > 100 ), newline ] ] )
	, gen_capture( [ [ gen_beof, `Email`, `:` ], buyer_email, s1, [ check( buyer_email(start) > 100 ), newline ] ] )
	
	, gen_capture( [ [ gen_beof, `Telephone`, `:` ], delivery_ddi, s1, [ check( delivery_ddi(start) > 100 ), newline ] ] )
	, gen_capture( [ [ gen_beof, `Facsimile`, `:` ], delivery_fax, s1, [ check( delivery_fax(start) > 100 ), newline ] ] )
	, gen_capture( [ [ gen_beof, `Email`, `:` ], delivery_email, s1, [ check( delivery_email(start) > 100 ), newline ] ] )

	, get_shipping_instructions

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
	
	, sender_name( `BHP` ) % 2 branches of BHP use these rules.
	
	, set( no_scfb )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYERS CODE FOR BUYER AND DELIVERY NOTE REFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyers_code_for_buyer_and_delivery_note_reference, [
%=======================================================================

	  q(0,6,line), buyers_code_for_buyer_line
	
] ).

%=======================================================================
i_line_rule( buyers_code_for_buyer_line, [
%=======================================================================

	  q0n( [ dummy(s1), tab ] )
	  
	, q0n(word)
	
	, read_ahead( or( [ `Olympic`, `Nickel`, `Worsley` ] ) )

	, generic_item( [ buyers_code_for_buyer_x, w, prepend( buyers_code_for_buyer_x( `AUBHP` ), ``, `` ) ] )
	
	, check( strip_string2_from_string1( buyers_code_for_buyer_x, ` `, Buyerx ) )
	, check( string_to_upper( Buyerx, Buyer ) )
	
	, buyers_code_for_buyer( Buyer )
	, delivery_note_reference( Buyer )
	, set( delivery_note_ref_no_failure )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================

	  q(0,30,line)
	
	, shipping_instructions_line_1
	
	, shipping_instructions_line_2
	
] ).

%=======================================================================
i_line_rule( shipping_instructions_line_1, [
%=======================================================================

	  `Invoice`, `Address`, `:`, tab
	
	, read_ahead( [ `Delivery`, `Address`, `/`, `Marking`, `Instructions` ] )
	
	, generic_item( [ shipping_instructions, s1, newline ] )
	
] ).

%=======================================================================
i_line_rule( shipping_instructions_line_2, [
%=======================================================================

	  nearest( shipping_instructions(start), 10, 10 )
	
	, q(2,1, [ append( shipping_instructions(s1), ` `, `` ), tab ] )
	
	, append( shipping_instructions(s1), ` `, `` ), newline
	
	, trace( [ `shipping_instructions`, shipping_instructions ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_section_end_line ).
%=======================================================================
i_line_rule( line_section_end_line, [ q0n(word), `Purchase`, `Order` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails( line_end_line )

		, or( [ line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Date`, tab, `Unit`, `Price`, tab, `Total`, `Price`, newline

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Total`, `:`, `AUD`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, q10( [ q0n( [ peek_fails( line_check_line ), peek_fails( line_end_line ), line ] )
	
		, line_item_line
		
	] )
	
	, q10( [ or( [ check( line_item = `FREIGHT` ), check( i_user_check( check_descr_for_freight, line_descr ) ) ] )
	
		, trace( [ `freight line, ignoring` ] )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_no( [ line_order_line_number, d, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, q10( generic_item( [ material_number, w, tab ] ) )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ delivery, date, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_check_line, [
%=======================================================================
   
	  q0n(anything)
	
	, generic_item( [ delivery, date, tab ] )
	
	, generic_no( [ check_, d, tab ] )
	
	, generic_no( [ check_, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
   
      or( [
	
		[ `Your`, `Material`, `Number` ]
		
		, [ `Item`, `No`, q10(`:`) ]
		
	] )
	
	, q10(tab)
	
	, generic_item( [ line_item, s1, newline ] )
	
] ).

%-----------------------------------------------------------------------
i_user_check( check_descr_for_freight, Descr )
%-----------------------------------------------------------------------
:-
	string_to_upper( Descr, Descr_U ),
	sys_string_split( Descr_U, ` `, Descr_list ),
	q_sys_member( Word, Descr_list ),
	q_sys_sub_string( Word, _, _, `FREIGHT` ),
	trace( `description contains freight` ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)

	, generic_horizontal_details( [ [ `Total`, `:`, `AUD` ], total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [
	
		[ with( invoice, delivery_charge, Charge )
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			, net_subtotal_2( Charge )
			, gross_subtotal_2( Charge )
		]
		
		, [ without( delivery_charge ), check( total_net = Net_1 ) ]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )
	
] ).