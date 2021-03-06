%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KENNARDS HIRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kennards_hire, `15 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, gen_capture( [ [ `Purchase`, `Order`, `Number` ], order_number, s1, newline ] )
	, gen_capture( [ [ `Date`, `:`, tab ], invoice_date, date, newline ] )
	
	, get_delivery_details

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
	
	, or( [ 
	  [ test(test_flag), suppliers_code_for_buyer(`10472213`) ]    %TEST
	    , suppliers_code_for_buyer(`11125931`)                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply(`SY`)
	
	, buyer_location(`16410356`)
	
	, delivery_from_location(`16410356`)
	
	, sender_name( `Kennards Hire Pty Ltd.` ) % 2 branches of BHP use these rules.
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q0n(line)

	, delivery_details_line
	
] ).

%=======================================================================
i_line_rule( delivery_details_line, [
%=======================================================================

	trace( [ `here` ] )

	, `Deliver`, `To`, `:`, q10(tab)
	
	, generic_item( [ partyx, sf, `|` ] )
	
	, or( [ 
	
		[ check( q_sys_sub_string( partyx, _, _, `CONCRETE CARE` ) ), delivery_party(`Kennards Concrete Care P/L`) ]
		
		, [ delivery_party(`Kennards Hire Pty Limited`) ]
		
	] )
	
	, generic_item( [ delivery_streetx, sf, `|` ] )
	
	, check( string_to_capitalised( delivery_streetx, DelivStr ) )
	
	, delivery_street(DelivStr)
	
	, generic_item( [ delivery_cityx, s ] )
	
	, check( string_to_upper( delivery_cityx, DelivCity ) )
	
	, delivery_city(DelivCity)
	
	, generic_item( [ delivery_state, w ] )
	
	, generic_item( [ delivery_postcode, d, newline ] )

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

	, qn0( [ peek_fails( line_end_line )

		, or( [ line_invoice_rule
		
			, line_invoice_line2

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Type`, tab, `Item`, `Code`, tab, `Supplier`, `Code`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [ [ `Total`, tab, `$`, a(d) ]
	  
		, [ `All`, `Invoices` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
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
   
	  generic_item( [ dummy, w, tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, q10( 
		read_ahead( [ q0n(word), `IN`
			, or( [ [ tab, set(avrnext), trace( [ `AVR is on the next line` ] ) ]
			
				, generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q10( dummy(s1) ), tab ] ] )
			] )
		] )
	)
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q10( [ append( line_descr(s1), ` `, `` ), tab ] )
	
	, generic_item( [ dummy, d, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_vat_amount, d, tab ] )
	
	, generic_item( [ line_total_amount, d, newline ] )
	
	, line_quantity_uom_code( `PC` )

	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line2, [
%=======================================================================
   
   read_ahead( [ dummy(s1), check( not( q_sys_sub_string( dummy, _, _, `Deliver` ) ) ), check( not( q_sys_sub_string( dummy, _, _, `Phone` ) ) ) ] )
   
	, trace( [ `here` ] ), read_ahead( [ append( line_descr(s1), ` `, `` ), q10( [ tab, append( line_descr(s1), ` `, `` ) ] ), newline ] )
	
	, q10( [ q0n(word)
		, or( [ [ `IN`, q10( `=` ) ]
			, [ set( regexp_allow_partial_matching ), in( f( [ begin, q(alpha("IN"),2,2), end ] ) ), clear( regexp_allow_partial_matching ) ] 
		] )
		, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) 
	] )
	
	, q10( [ test(avrnext), generic_item( [ line_item, d ] ) ] )
	
	, clear(avrnext)
	
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
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================
	
	`Total`, tab
	
	, generic_item( [ total_vat, d, tab ] )
	
	, generic_item( [ total_invoice, d, newline ] )
	
] ).