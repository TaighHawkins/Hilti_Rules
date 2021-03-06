%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US IOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_iof, `18 August 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_user_field( invoice, additional_email_text, `Additional text` ).
i_user_field( invoice, additional_email_text, `Additional text` ).

i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ):- result( _, invoice, type_of_supply, ToS ), not( q_sys_member( ToS, [ `04`, `05` ] ) ).

i_op_param( output, _, _, _, orders05_idoc_xml ).

i_op_param( xml_transform( Var, In ), _, _, _, Out )
:-
	q_sys_member( Var, [ delivery_ddi, buyer_ddi ] ),
	strip_string2_from_string1( In, `()- `, Stripped ),
	extract_pattern_from_back( Stripped, Out, [ dec, dec, dec, `-`, dec, dec, dec, `-`, dec, dec, dec, dec ] )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_suppliers_code_for_buyer
	, get_agent_code_3

	, get_order_date	
	, get_order_number
	, get_delivery_date
	, get_buyers_code_for_location
	
	, get_buyer_contact
	, get_buyer_ddi
	, get_buyer_email
	
	, get_delivery_note_reference
	, get_delivery_details
	, get_delivery_contact
	, get_delivery_ddi
	, get_delivery_email
	
	, get_shipping_instructions
	, get_customer_comments
	
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

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]   	%TEST
	    , supplier_registration_number( `P11_100` )                    	%PROD
	] )

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `US IoF` )

	, set( no_uom_transform )
	, set( no_contract_order_ref )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROUTING INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	  q(0,10,line)
	  
	, generic_horizontal_details( [ [ at_start, generic_item( [ suppliers_code_for_buyer, s1, newline ] ) ] ] )
	
	, generic_horizontal_details( [ [ `Sold`, `To` ] ] )
	, check( suppliers_code_for_buyer(start) < generic_hook(end) )
	
] ).

%=======================================================================
i_rule( get_agent_code_3, [ 
%=======================================================================

	last_line
	
	, q(0,10,up)
	
	, generic_line( [ [ 
		q0n( [ dummy(s1), tab ] )
		, or( [ [ `US`, set( us ) ]
			, [ `CA`, set( ca ) ] 
		] )
		, `,`, q10( `IOF` )
		, company(sf), q10( `,` ), `Version` 
	] ] )
	, trace( [ `Company`, company ] )
	
	, or( [ [ test( us ), agent_code_3( `6000` ), buyer_registration_number( `US-IOF` ), trace( [ `US` ] ) ]
	
		, [ test( ca ), agent_code_3( `6800` ), buyer_registration_number( `CA-IOF` ), trace( [ `Canada` ] ) ]
	] )
	
	, or( [ [ test( ca ), custom_notification_address( `CACSEDI-EN@hilti.com` ) ]
	
		, [ test( us ), check( i_user_check( check_for_notification_address, company, Email ) )
			, custom_notification_address( Email )
			, trace( [ `Email ntofication will be sent to`, Email ] )
		]
		
		, [ force_result( `defect` ), force_sub_result( `unknown_destination_email` )
			, trace( [ `Unable to determine destination address` ] )
		]
	] )
	
	, check( string_to_upper( company, CompanyU ) )
	, additional_email_text( CompanyU )
	
] ).

%=======================================================================
i_user_check( check_for_notification_address, Company, Email )
%-----------------------------------------------------------------------
:-	
	string_to_lower( Company, CompanyL ),
	company_to_email_destination( CompanyKeyWord, Email ),
	q_sys_sub_string( CompanyL, _, _, CompanyKeyWord )
.
%=======================================================================
%=======================================================================
company_to_email_destination( `lasco`, `hiltiselect@hilti.com` ).
company_to_email_destination( `millard`, `hiltiselect@hilti.com` ).
company_to_email_destination( `midwest`, `hiltiselect@hilti.com` ).
company_to_email_destination( `macon`, `hiltiselect@hilti.com` ):- i_mail( to, `orders.test@ecx.adaptris.com` ).
% TEST company_to_email_destination( `lasco`, `taigh.hawkins@egsgroup.com` ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER ID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,7,line)
	  
	, generic_vertical_details( [ [ `Purchase`, `Order`, `#` ], `Purchase`, q(0,1), (end,50,50), order_number, s1, newline ] )

	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Date`, `:` ], 250, invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_delivery_date, [ 
%=======================================================================

	  q(0,40,line), generic_horizontal_details( [ [ `Requested`, `Delivery`, `Date` ] ] )
	  
	, generic_line( [ [ q10( [ delivery_date( date( `m/d/y` ) ), tab ] ), shipping(s1) ] ] )
	
	, check( i_user_check( convert_shipping_to_values, shipping, ToS, CC ) )
	
	, type_of_supply( ToS )
	, cost_centre( CC )
	
	, q10( [ with( delivery_date ), trace( [ `Delivery date`, delivery_date ] ) ] )
	, trace( [ `Shipping:`, ToS, CC ] )
	
	, q10( [ check( shipping = `CHARGE CUSTOMER SHIPPING ACCOUNT` )
		, set( charge )
	] )
	
	, q10( [
		or( [ check( shipping = `WILL CALL - CUSTOMER PICKUP` )
			, check( shipping = `WILL CALL - HILTI SALESMAN PICKUP` )
		] )
		
		, or( [ [ without( additional_email_text )
				, additional_email_text( ` - WILL CALL - REVIEW AND RELEASE` )
			]
			
			, [ with( invoice, additional_email_text, Email )
				, check( strcat_list( [ Email, ` - WILL CALL - REVIEW AND RELEASE` ], NewEmail ) )
				, remove( additional_email_text )
				, additional_email_text( NewEmail )
			]
		] )
		, trace( [ `Added additional email text` ] )
	] )
	
] ).

%=======================================================================
i_user_check( convert_shipping_to_values, Ship, ToS, CC )
%=======================================================================
:-
	string_to_upper( Ship, ShipU ),
	shipping_cons_lookup( ShipU, ToS, CC )
.

shipping_cons_lookup( `STANDARD UPS`, `01`, `Standard` ).
shipping_cons_lookup( `WILL CALL - CUSTOMER PICKUP`, `04`, `Collection_Cust` ).
shipping_cons_lookup( `WILL CALL - HILTI SALESMAN PICKUP`, `05`, `Collection_TS` ).
shipping_cons_lookup( `2 - 4 DAY GROUND`, `NC`, `Saver 2-4 day Ground` ).
shipping_cons_lookup( `CHARGE CUSTOMER SHIPPING ACCOUNT`, `N4`, `HNA - Cust Acct` ).
shipping_cons_lookup( `LOCAL COURIER - JOBSITE 4 HOURS (ORDER BY 11:00 AM)`, `NM`, `Jobsite_ FourHours` ).
shipping_cons_lookup( `LOCAL COURIER - JOBSITE NEXT DAY`, `NN`, `HNA:JOBSITE_NEXT_AM` ).
shipping_cons_lookup( `OVERNIGHT AIR`, `N7`, `HNA:Air Priority` ).
shipping_cons_lookup( `SATURDAY DELIVERY`, `N9`, `HNA:Saturday_Delvry` ).

%=======================================================================
i_rule( get_buyers_code_for_location, [ test( charge ),
%=======================================================================

	  q(0,40,line), generic_vertical_details( [ [ `Shipping`, `Account`, `#` ], `Account`, q(0,0), (start,50,50), buyers_code_for_location, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line)

	, generic_vertical_details( [ [ `Buyer`, `Name` ], `Buyer`, q(0,0), (start,10,10), buyer_contact, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_buyer_ddi, [
%=======================================================================

	q(0,15,line)

	, generic_vertical_details( [ [ `Buyer`, `Phone`, `:` ], `Buyer`, q(0,1), (start,10,10), buyer_ddi, s1
		, [ newline
			, check( not( q_sys_sub_string( buyer_ddi, _, _, `EMAIL` ) ) )
			, check( not( q_sys_sub_string( buyer_ddi, _, _, `@` ) ) )
			, check( not( q_sys_sub_string( buyer_ddi, _, _, `SHIP` ) ) ) 
		] 
	] )

] ).

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	q(0,15,line)

	, generic_vertical_details( [ [ `EMAIL`, `:` ], `Email`, q(0,0), (start,10,10), buyer_email, s1, [ check( q_sys_sub_string( buyer_email, _, _, `@` ) ), newline ] ] )
	
	, q(0,4,line), generic_horizontal_details( [ [ `Ship`, `To` ] ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_vertical_details( [ [ `Ship`, `Attn`, `Name` ], `Ship`, q(0,0), (start,10,10), delivery_contact, s1, check( not( q_sys_sub_string( delivery_contact, _, _, `SHIP` ) ) ) ] )
	
] ).

%=======================================================================
i_rule( get_delivery_ddi, [ with( delivery_contact ),
%=======================================================================

	  q(0,25,line)
	  
	, generic_vertical_details( [ [ `Ship`, `Phone` ], `Ship`, q(0,0), (start,10,10), delivery_ddi, s1, check( not( q_sys_sub_string( delivery_ddi, _, _, `EMAIL` ) ) ) ] )
	
] ).

%=======================================================================
i_rule( get_delivery_email, [ with( delivery_contact ),
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Ship`, `Phone` ] ] )
	
	, q(0,5,line)

	, generic_vertical_details( [ [ `Email` ], `Email`, q(0,0), (start,10,10), delivery_email, s1, check( q_sys_sub_string( delivery_email, _, _, `@` ) ) ] )
	
] ).

%=======================================================================
i_rule( get_delivery_note_reference, [ 
%=======================================================================

	  q(0,15,line)

	, generic_horizontal_details( [ [ `Ship`, `To` ] ] )
	
	, q(0,8,line)
	
	, generic_horizontal_details( [ delivery_note_reference, sf, [ q10( tab ), `Delivery`, check( delivery_note_reference(font) = 1 ) ] ] )
	, set( delivery_note_ref_no_failure )
	
] ).

%=======================================================================
i_rule( get_delivery_details, [ without( delivery_note_reference ),
%=======================================================================

	q(0,15,line)

	, read_ahead( generic_horizontal_details( [ [ `Ship`, `To` ] ] ) )
	
	, generic_horizontal_details( [ [ `Ship`, `To`, `:` ], delivery_party, s1 ] )
	
	, or( [ generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_dept, s1, peek_fails( [ q10( tab ), `Ship`, `Phone` ] ) ] )
		, q10( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	] )
	
	, or( [ [ generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_location, s1, [ tab, `Ship`, `Phone` ] ] )
			, remove( delivery_party )
			, remove( delivery_dept )
		]
		
		, [ q10( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
	
			, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, sf, or( [ `(`, gen_eof, `Ship` ] ) ] )
			
			, or( [ gen_line_nothing_here( [ generic_hook(start), 10, 10 ] )
				, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] ) 
			] )
			
			, delivery_city_state_pc
		]
	] )

] ).

%=======================================================================
i_line_rule( delivery_city_state_pc, [ 
%=======================================================================

	nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ delivery_city, sf, q10( `,` ) ] )
	
	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
	, or( [ generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
		, generic_item( [ delivery_postcode, s1 ] )
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY INFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Ship`, `Attn`, `Name` ] ] )
	, check( generic_hook(start) = Left )
	
	, q(0,15,line), generic_horizontal_details( [ [ `Delivery`, `Instructions` ] ] )
	, shipping_instructions( `` )
	, picking_instructions( `` )
	, packing_instructions( `` )
	
	, q0n(
		or( [ shipping_loop_rule( [ Left ] )
			
			, line
		] )
	)
	, generic_horizontal_details( [ `Comments` ] )
	
] ).

%=======================================================================
i_rule( shipping_loop_rule( [ Left ] ), [ 
%=======================================================================

	generic_line( 1, Left, 500, [ generic_item( [ shipping, s1 ] ) ] )
	, check( shipping = Ship )
	, append( shipping_instructions( Ship ), ``, ` ` )
	, append( picking_instructions( Ship ), ``, ` ` )
	, append( packing_instructions( Ship ), ``, ` ` )

] ).

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Ship`, `Attn`, `Name` ] ] )
	, check( generic_hook(start) = Left )
	
	, q(0,20,line), generic_horizontal_details( [ [ `Comments` ] ] )
	, customer_comments( `` )
	
	, q0n(
		or( [ generic_line( 1, Left, 500, [ append( customer_comments(s1), ``, ` ` ) ] )
			
			, line
		] )
	)
	, generic_horizontal_details( [ `Requested` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	qn0(line), generic_horizontal_details( [ [ `Total`, `Purchase`, dummy(s1) ], 400, total_net, d ] )
	
	, check( total_net = Net )
	, total_invoice( Net )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ 
	
		or( [  line_invoice_line
	
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	q0n(anything), read_ahead( `Item` ), item_hook(s1)
	
	, q0n(anything), read_ahead( `Cust` ), cust_hook(s1)
	, q0n(anything), read_ahead( `UoM` ), uom_hook(s1)
	, q0n(anything), read_ahead( `cost` ), cost_hook(s1)
	, q0n(anything), read_ahead( `Total` ), total_hook(s1)
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  check( item_hook(end) = ItemHookRaw )
	, check( sys_calculate( ItemHook, ItemHookRaw + 10 ) )
	
	, check( cust_hook(start) = CustHookRaw )
	, check( sys_calculate( CustHook, CustHookRaw - 10 ) )
	
	, check( cust_hook(end) = CustEndRaw )
	, check( sys_calculate( CustEndHook, CustEndRaw + 5 ) )
	
	, check( uom_hook(start) = UoMHookRaw )
	, check( sys_calculate( UoMHook, UoMHookRaw - 20 ) )
	
	, check( uom_hook(end) = UoMEndRaw )
	, check( sys_calculate( UoMEndHook, UoMEndRaw + 20 ) )
	
	, check( total_hook(start) = TotalHookRaw )
	, check( sys_calculate( TotalHook, TotalHookRaw - 25 )  )
	
	, retab( [ ItemHook, CustHook, CustEndHook, UoMHook, UoMEndHook, TotalHook ] )
	
	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, q10( line_item_for_buyer(s1) ), tab
	
	, generic_item_cut( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity_uom_code_x, s1, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d, newline ] )
	
	, count_rule
	
	, q10( [ with( invoice, delivery_date, Date )
		, line_original_order_date( Date )
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