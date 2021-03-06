%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US ADVANCED CONNECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_advanced_connections, `4 June 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( `m/d/y` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, gen_vert_capture( [ [ `PURCHASE`, `ORDER`, newline ], `PURCHASE`, start, 0, 20, order_number, s1 ] )
	, gen_vert_capture( [ [ `PURCHASE`, `ORDER`, newline ], `ORDER`, start, invoice_date, date ] )

	, get_delivery_address
	, gen_capture( [ [ `ATT`, `:` ], delivery_contact, sf, or( [ newline, `-`, a(d) ] ) ] )
	
	, get_buyer_email
	, get_buyer_contact_lookup
	, gen_capture( [ [ `Phone`, `:` ], buyer_ddi, sf, `Fax` ] )
	, gen_capture( [ [ `Fax`, `:` ], buyer_fax, s1, newline ] )
	
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

%%%%%%%%% FIXED %%%%%%%%%

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%%%%%%%%%%%%%%%%%%%%%%%%%

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11263962` ) ]    %TEST
	    , suppliers_code_for_buyer( `15817784` )                      %PROD
	]) ]
	
	, sender_name( `Advanced Connections, Inc.` )
	
	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  or( [
	
		get_delivery_address_rule
		
		, [ delivery_note_number( `19454987` ), trace( [ `delivery_note_number`, delivery_note_number ] )
			, shipping_instructions( `6264: Hold for customer collection on` ), trace( [ `shipping_instructions`, shipping_instructions ] )
			, picking_instructions( `6264: Hold for customer collection on` ), trace( [ `picking_instructions`, picking_instructions ] )
			, packing_instructions( `6264: Hold for customer collection on` ), trace( [ `packing_instructions`, packing_instructions ] )
		]
		
	] )

] ).

%=======================================================================
i_rule_cut( get_delivery_address_rule, [ 
%=======================================================================

	  q0n(line)
	
	, delivery_party_line
	
	, delivery_street_line
	
	, q01( [ line, delivery_street_append, line ] )
	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_party_line, [
%=======================================================================

	  `R`, tab, a(s1), tab, `S`, tab
	
	, generic_item( [ delivery_party, s1, newline ] )

] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	
	, generic_item( [ delivery_street, s1, newline ] )

] ).

%=======================================================================
i_line_rule( delivery_street_append, [
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	
	, append( delivery_street(s1), ` `, `` ), newline

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	
	, peek_fails( `CARROLLTON` )

	, generic_item( [ delivery_city, sf, `,` ] )
	
	, `TEXAS`, delivery_state( `TX` )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ], newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	  buyer_email( From ), trace( [ `buyer_email`, buyer_email ] )

] ):- i_mail( from, From ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER CONTACT LOOKUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact_lookup, [
%=======================================================================

	  buyer_contact( CONTACT ), trace( [ `buyer_contact`, buyer_contact ] )

] )
:-
	i_mail( from, FROM ),
	string_to_lower( FROM, From ),
	contact_lookup( From, CONTACT ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [
		
			line_invoice_line
			
			, sales_tax_line
			
			, generic_descr_append
			
			, line
		
		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `PART`, `NUMBER`, tab, `DESCRIPTION`, tab, `DATE`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	  `Total`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	  generic_no( [ part_no_, d, [ `)`, tab ] ] )
	
	, q10( read_ahead( or( [
	
				[ q0n(word), `(`, generic_item( [ line_item, [ begin, q(dec,4,10), end ], or( [ `)`, tab ] ) ] ) ]
				
				, [ q0n(word), generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] ) ]
				
	] ) ) )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ req_date_, date, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( sales_tax_line, [
%=======================================================================
	
	  read_ahead( [ `Sales`, `Tax` ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
	, line_type( `ignore` )

	, check( line_net_amount = Net )

	, delivery_charge( Net )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ gen_beof, `Total` ], 200, total_net, d, newline ] )

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

contact_lookup( `carlosb@acicabling.com`, `CARLOS BAKER` ).
contact_lookup( `larryb@acicabling.com`, `LARRY BROWN` ).
contact_lookup( `tommyc@acicabling.com`, `TOMMY CHANDLER` ).
contact_lookup( `janp@acicabling.com`, `JAN PEMBLETON` ).
contact_lookup( `mikea@acicabling.com`, `MIKE AUSLEY` ).
contact_lookup( `acct.pay@acicabling.com`, `ACCOUNTS PAYABLE` ).
contact_lookup( `rray@acicabling.com`, `RON RAY` ).
contact_lookup( `rroldan@acicabling.com`, `RANDY ROLDAN` ).
contact_lookup( `conc@acicabling.com`, `DON CARTER` ).
contact_lookup( `arnulfo.ruiz@hcihealthcare.com`, `ARNULFO RUIZ` ).