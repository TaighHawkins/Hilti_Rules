%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TECK METALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( teck_metals, `21 July 2014` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_supplier_rule( purchase_order_rule ).
%=======================================================================
i_rule( purchase_order_rule, [ q( 0, 2, line), purchase_order_line ] ).
%=======================================================================
i_line_rule( purchase_order_line, [ q0n(anything), `Purchase`, `Order` ] ).
%=======================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( _ ).

i_include_partner_attachments_image_only.

i_op_param( send_original( _ ), _, _, _, false ).
i_op_param( send_pdf_image( _ ), _, _, _, true ).

%i_format_postcode( X,X ).

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `TECK METALS LTD.` ), _, _, _, _) 
:- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME2, `TECK METALS LTD.` ), _, _, _, _) 
:- result( _, invoice, delivery_contact, NU2 ), string_to_upper(NU2, NAME2).

i_user_field( invoice, net_subtotal_x, `net_storage` ).
i_user_field( invoice, picking, `Picking` ).

i_orders05_idocs_e1edkt1( `Z012`, picking ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ look_for_fleet ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( look_for_fleet, [ 
%=======================================================================

	or( [ [ q0n(line), line_header_line
	
			, q(0,30,line), look_for_fleet_line
			
			, delivery_note_reference( `by_rule` )
			
		]
	
		, set( normal_order )
		
	] )

] ).

%=======================================================================
i_line_rule( look_for_fleet_line, [ q0n(anything), `Fleet`] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_order_number
	
	, get_fixed_details
	
	, get_shipping_details
	
	, get_buyer_and_delivery_details
	
	, get_invoice_date
	
	, get_shipping_instructions
	
	, get_invoice_lines
	
	, get_invoice_totals

] ):- grammar_set( normal_order ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q( 0, 5, line )
	
	, order_number_line
	
	, or( [ [ check( sys_string_length( order_number, Length ) )
	
			, check( q_sys_sub_string( order_number, Length, 1, `W` ) )
	
			, delivery_note_number(`14118840`)
			
			, trace( [ `Delivery Note Number`, delivery_note_number ] )
		
		]
		
		, [ delivery_party(`TECK METALS LTD`), set( no_w )

			, trace( [ `Delivery Party`, delivery_party ] )

		]
		
	] )

] ).

%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	q0n(anything)
	
	, `Purchase`, `Order`, tab
	
	, order_number(s1), newline
	
	, trace( [ `Order Number`, order_number ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_details, [
%=======================================================================

	buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, or( [ [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST

		, supplier_registration_number( `P11_100` )                      %PROD

	] )

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, or( [ [ test(test_flag), suppliers_code_for_buyer( `11247373` ) ]   %TEST
		
		, suppliers_code_for_buyer( `10670104` )                      %PROD
	
	] )
	
	, type_of_supply(`01`)
	
	, cost_centre(`Standard`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_details, [
%=======================================================================

	test( no_w )
	
	, q( 0, 6, line )
	
	, shipping_address_line
	
	, q( 0, 2, line)
	
	, address_line_1( 1, -110, 250 )
	
	, address_line_2( 1, -110, 250 )
	
	, address_line_3( 1, -110, 250 )
	
	, address_line_4( 1, -110, 250 )
	
	, address_line_5( 1, -110, 250 )

] ).

%=======================================================================
i_line_rule_cut( shipping_address_line, [
%=======================================================================

	q0n(anything)
	
	, `Shipping`, `Address`, `:`

] ).

%=======================================================================
i_line_rule_cut( address_line_1, [
%=======================================================================

	trace( [ `Address Line 1` ] )
	
	, or( [ [ `TECK`, `METALS`, `LTD`, `.`, gen_eof ]
	
		, [ delivery_dept(s1), gen_eof
		
			, trace( [ `Delivery Dept`, delivery_dept ] )
		
		]
	
	] )

] ).

%=======================================================================
i_line_rule_cut( address_line_2, [
%=======================================================================

	trace( [ `Address Line 2` ] )
	
	, delivery_dept(s1), gen_eof

	, trace( [ `Delivery Dept`, delivery_dept ] )

] ).

%=======================================================================
i_line_rule_cut( address_line_3, [
%=======================================================================

	trace( [ `Address Line 3` ] )
	
	, delivery_street(s1), newline
	
	, trace( [ `Delivery Street 2`, delivery_street ] )

] ).

%=======================================================================
i_line_rule_cut( address_line_4, [
%=======================================================================

	trace( [ `Address Line 4` ] )
	
	, delivery_street(s1), newline
	
	, trace( [ `Delivery Street 2`, delivery_street ] )

] ).

%=======================================================================
i_line_rule_cut( address_line_5, [
%=======================================================================

	trace( [ `Address Line 5` ] )
	
	, delivery_city(sf)
	
	, trace( [ `Delivery City`, delivery_city ] )
	
	, delivery_state( f( [ begin, q( alpha, 2, 2), end ] ) )
	
	, trace( [ `Delivery State`, delivery_state ] )
	
	, delivery_postcode( f( [ begin, q( alpha, 1, 1 ), q( dec, 1, 1 ), q( alpha, 1, 1 ), end ] ) )

	, append( delivery_postcode( f( [ begin, q( dec, 1, 1 ), q( alpha, 1, 1 ), q( dec, 1, 1 ), end ] ) ), ``, `` )
	
	, trace( [ `Delivery Postcode`, delivery_postcode ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_details, [
%=======================================================================

	q0n(line)
	
	, buyer_ddi_line
	
	, q( 0, 3, line )
	
	, buyer_fax_line
	
	, q( 0, 3, line )
	
	, buyer_email_line
	
	, check( buyer_contact = Buyer_Contact )
	
	, delivery_contact(Buyer_Contact)
	
	, check( buyer_ddi = Buyer_DDI )
	
	, delivery_ddi(Buyer_DDI)
	
	, check( buyer_fax = Buyer_Fax )
	
	, delivery_fax(Buyer_Fax)
	
	, check( buyer_email = Buyer_Email )
	
	, delivery_email(Buyer_Email)

] ).
	
%=======================================================================
i_line_rule( buyer_ddi_line, [
%=======================================================================

	q0n(anything), `Phone`, `:`, tab
	
	, buyer_ddi(s1), newline
	
	, trace( [ `Buyer DDI`, buyer_ddi ] )

] ).
	
%=======================================================================
i_line_rule( buyer_fax_line, [
%=======================================================================

	q0n(anything), `Fax`, `:`, tab
	
	, buyer_fax(s1), newline
	
	, trace( [ `Buyer Fax`, buyer_fax ] )

] ).

%=======================================================================
i_line_rule( buyer_email_line, [
%=======================================================================

	q0n(anything), `Email`, `:`, tab
	
	, read_ahead( [ buyer_email(s1), newline ] )
	
	, trace( [ `Buyer Email`, buyer_email ] )
	
	, buyer_contact(w), `.`
	
	, append( buyer_contact(w), ` `, ``), `@`
	
	, trace( [ `Buyer Contact`, buyer_contact ] )

] ).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [
%=======================================================================

	q( 0, 5, line )
	
	, invoice_date_line

] ).
	
%=======================================================================
i_line_rule( invoice_date_line, [
%=======================================================================

	q0n(anything), `Date`, `:`, tab
	
	, invoice_date( date(`y-m-d`) ), newline
	
	, trace( [ `Invoice Date`, invoice_date ] )

] ).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================

	q( 0, 14, line)
	
	, shipping_instructions_line( 1, -110, 250 )
	
	, q10(shipping_instructions_append( 1, -110, 250 ))

] ).

%=======================================================================
i_line_rule( shipping_instructions_line, [
%=======================================================================

	trace( [ `Shipping Instructions Line` ] )
	
	, q0n(anything), read_ahead( [ `Attn`, `:` ] )
	
	, read_ahead( picking(s1) )
	
	, trace( [ `Picking`, picking ] )
	
	, shipping_instructions(s1), gen_eof
	
	, trace( [ `Shipping Instructions`, shipping_instructions ] )

] ).

%=======================================================================
i_line_rule( shipping_instructions_append, [
%=======================================================================

	trace( [ `Shipping Instructions Append` ] )
	
	, q0n(anything), read_ahead( [ `Work`, `Order` ] )
	
	, read_ahead( append( picking(s1), `~`, `` ) )
	
	, trace( [ `Picking`, picking ] )
	
	, append( shipping_instructions(s1), `~`, `` ), gen_eof
	
	, trace( [ `Shipping Instructions`, shipping_instructions ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line
	
	, qn0( [ peek_fails(line_end_line)

		, or( [ line_invoice_rule
		
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Line`, tab, `Item`, `Description`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `*`, `Do`, `not`, `substitute` ]
	
		, [ `Incoterms`, `:`, tab ]
	
	] )

] ).

%=======================================================================
i_rule( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, q10( [ peek_fails( line_invoice_line), line_descr_line_2 ] )
	
	, q10( line_descr_line_3 )
	
	, q( 3, 0, line_descr_append )
	
	, q10( [ peek_fails( test( line_item_on_line_1 ) )
	
		, peek_fails( test( line_item_on_line_2 ) )
		
		, peek_fails( test( line_item_on_line_3 ) )
		
		, line_item(`missing`)
		
	] )
	
	, clear( line_item_on_line_1 )
	
	, clear( line_item_on_line_2 )
	
	, clear( line_item_on_line_3 )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_order_line_number(d), tab
	
	, trace( [ `Line Order Line Number`, line_order_line_number ] )
	
	, or( [ [ line_descr(s), q10( `#` )
	
			, trace( [ `Description`, line_descr ] )
	
			, line_item( f( [ begin, q( dec, 4, 14 ), end ] ) )
			
			, trace( [ `Item Code Case 1`, line_item ] )
			
			, set( line_item_on_line_1 )
			
		]
		
		, [ line_descr(s1)
	
			, trace( [ `Description`, line_descr ] )
			
		]

	] ), tab
	
	, q10( [ line_item_for_buyer(s1), tab
	
		, trace( [ `Line Item For Buyer`, line_item_for_buyer ] )
		
	] )
	
	, line_quantity(d), tab
	
	, trace( [ `Quantity`, line_quantity ] )
	
	, dummy_uom_code(w), tab
	
	, line_unit_amount(d), tab
	
	, trace( [ `Unit Amount`, line_unit_amount ] )
	
	, line_net_amount(d), tab, dummy(w), newline
	
	, trace( [ `Line Net Amount`, line_net_amount ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line_2, [
%=======================================================================

	peek_fails( [ or( [ [ `*`, `Do`, `not`, `substitute` ]
	
			, [ `Incoterms`, `:`, tab ]
			
		] )
	
	] )
	
	, or( [ [ or( [ [ peek_fails( test( line_item_on_line_1 ) )
	
					, line_item( f( [ begin, q( dec, 4, 14 ), end ] ) )
			
					, trace( [ `Item Code Case 2`, line_item ] )
					
					, append( line_descr(s1), ` `, `` ), newline
	
					, trace( [ `Description`, line_descr ] )
			
				]
		
				, [ peek_fails( test( line_item_on_line_1 ) )
			
					, trace( [ `In 2nd Option` ] )
	
					, `P`, `/`, `N`, `.`
				
					, trace( [ `Found P/N` ] )
		
					, line_item( f( [ begin, q( dec, 4, 14 ), end ] ) ), newline
			
					, trace( [ `Item Code Case 3`, line_item ] )
			
				]
		
				, [ peek_fails( test( line_item_on_line_1 ) )
			
					, trace( [ `In 3rd Option` ] )
	
					, `PT`, `#`
				
					, trace( [ `Found PT` ] )
		
					, line_item( f( [ begin, q( dec, 4, 14 ), end ] ) )
			
					, trace( [ `Item Code Case 4`, line_item ] )
					
					, q10( [append( line_descr(s1), ` `, `` ), newline
	
						, trace( [ `Description`, line_descr ] )
						
					] )
			
				]
		
			] )
		
			, set( line_item_on_line_2 )
			
		]
		
		, [ append( line_descr(s1), ` `, `` ), newline
	
		, trace( [ `Description`, line_descr ] )
		
		]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line_3, [
%=======================================================================

	peek_fails( [ or( [ [ `*`, `Do`, `not`, `substitute` ]
	
			, [ `Incoterms`, `:`, tab ]
			
		] )
	
	] )
	
	, q10( [ peek_fails( test( line_item_on_line_1 ) )

		, peek_fails( test( line_item_on_line_2 ) )

		, line_item( f( [ begin, q( dec, 4, 14 ), end ] ) )

		, trace( [ `Item Code Case 5`, line_item ] )

		, set( line_item_on_line_3 )

	] )
	
	, append( line_descr(s1), ` `, `` ), newline
	
	, trace( [ `Description`, line_descr ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_append, [
%=======================================================================

	peek_fails( [ or( [ [ `*`, `Do`, `not`, `substitute` ]
	
			, [ `Incoterms`, `:`, tab ]
			
		] )
	
	] )
	
	, append( line_descr(s1), ` `, `` ), newline
	
	, trace( [ `Description`, line_descr ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	q0n(line)
	
	, line_header_line
	
	, qn0( [ or( [ get_line_net( 1, 310, 420 )
		
			, line
			
		] )

	] )

] ).

%=======================================================================
i_line_rule( get_line_net, [
%=======================================================================

	line_amount_net( fd( [ begin, q( [ dec, other_skip( ",'" ) ], 1, 10 ), q( other( "." ), 1, 1 ), q( dec, 2, 2 ), end ] ) )
	
	, trace( [ `Line Net Amount`, line_amount_net ] )
	
	, or( [ [ without(total_net)
	
			, check( line_amount_net = Total_Net )
			
			, total_net(Total_Net)
			
		]
		
		, [ with(total_net)
			
			, check( sys_calculate_str_add( total_net, line_amount_net, Total_Net ) )
			
			, total_net(Total_Net)
			
		]

	] )
	
	, trace( [ `Total Net Amount`, total_net ] )

	, total_invoice(Total_Net)
	
	, trace( [ `Total (Gross) Amount`, total_invoice ] )

] ).



