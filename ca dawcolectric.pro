%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CA DAWCOELECTRIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ca_dawcoelectric, `22 December 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_contact

	, get_delivery_location

	, get_shipping_information

	, get_order_date
	
	, get_order_number
	
	, get_buyer_email
	
	, get_buyer_contact

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_lines

	, get_totals
	
	, set( enable_duplicate_check )

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

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `10453936` ) ]
		, suppliers_code_for_buyer( `10688000` )
	] )
	
	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `NN` )
	
	, cost_centre( `HNA:JOBSITE_NEXT_AM` )
	
	, buyer_ddi( `514-738-3033` )
	
	, buyer_fax( `514-738-9507` )
	
	, delivery_party( `DAWCOLECTRIC LIMITEE` )
	
	, sender_name( `Dawcolectric Limitee` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [
%=======================================================================

	
	  q(0,10,line)
	
	, delivery_start_line
	
	, q10( [ without( delivery_dept ), delivery_dept_line ] )
	
	, or( [ [ check( i_user_check( party_lookup, delivery_dept, Street, City, PC, State ) )
	
			, delivery_street( Street )
			
			, delivery_city( City )
			
			, delivery_postcode( PC )
			
			, delivery_state( State )
			
		]
		
		, [ delivery_street_line

			, delivery_city_state_and_postcode_line
			
		]
		
	] )

] ).

%=======================================================================
i_line_rule( delivery_start_line, [ q0n(anything), read_ahead( [ `Ship`, `to` ] ), hook(s1), newline ] ).
%=======================================================================
i_line_rule( delivery_start_line, [ 
%=======================================================================

	q0n(anything), `Ship`, `to`, `:`, q10( tab )
	
	, read_ahead( hook(s1) ), generic_item( [ delivery_dept, s1, newline ] ) 

] ).


%=======================================================================
i_line_rule( delivery_dept_line, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ delivery_dept, sf, or( [ `(`, newline ] ) ] )

] ).

%=======================================================================
i_user_check( party_lookup, Party, Street, City, PC, State ):- dawco_address_lookup( Party, Street, City, PC, State ).
%=======================================================================

dawco_address_lookup( `BOMBARDIER FAL`, `13100 BOUL HENRI FABRE`, `MIRABEL`, `J7N 3C6`, `QC` ).
dawco_address_lookup( `BOMBARDIER`, `13100 BOUL HENRI FABRE`, `MIRABEL`, `J7N 3C6`, `QC` ).
dawco_address_lookup( `SIEMENS POSTE BELANGER`, `4800 RUE JEAN-TALON EST`, `SAINT-LEONARD`, `H1S 1K2`, `QC` ).
dawco_address_lookup( `MERCK`, `16750 ROUTE TRANS-CANADA`, `KIRKLAND`, `H9H 4M7`, `QC` ).
dawco_address_lookup( `ENTREPOT TROIS-RIVIÈRES`, `9125 BOUL PARENT`, `TROIS-RIVIÈRES`, `G9A 5E1`, `QC` ).
dawco_address_lookup( `ENTREPOT 2014`, `11127 Av L-j-forget`, `ANJOU`, `H1J 1Z8`, `QC` ).


%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ delivery_street, s1, newline ] )

] ).

%=======================================================================
i_line_rule( delivery_city_state_and_postcode_line, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, q10( [ read_ahead( `Laval` ), set( laval ), type_of_supply( `01` ), cost_centre( `Standard` ) ] )
	
	, generic_item( [ delivery_city, sf, q10( `,` ) ] )

	, q10( generic_item( [ delivery_state, w ] ) )
	
	, generic_item( [ delivery_postcode, sf
		, [ check( delivery_postcode = PC )
			, check( q_regexp_match( `^\\D\\d\\D.\\d\\D\\d$`, PC, _ ) ) 
		]
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

	with( invoice, delivery_party, Party ), with( invoice, delivery_street, Street )
	
	, with( invoice, delivery_postcode, PC ), with( invoice, delivery_city, City )
	
	, with( invoice, delivery_state, State ), with( invoice, delivery_contact, Contact )
	
	, or( [ with( invoice, delivery_ddi, DDI ), check( DDI = `` ) ] )
	
	, check( Laval = `HC Laval - please ship courier ST-LAURENT to jobsite~` )
	
	, check( strcat_list( [ Laval, `Contact: `, Contact, ` `, DDI, `~`, Party, `~`, Street, `~`, City, ` `, State, ` `, PC ], Notes ) )
	
	, shipping_instructions( Notes )
	
	, picking_instructions( Notes )
	
	, packing_instructions( Notes )
	
	, trace( [ `Notes`, Notes ] )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,20,line), generic_vertical_details( [ [ `Date`, tab, `Transport` ], invoice_date_x, s1 ] )
	  
	, check( invoice_date_x = Date_x )
	
	, check( sys_string_split( Date_x, `/`, [ Y, M, D ] ) )
	
	, check( stringlist_concat( [ D, M, Y ], `/`, Date ) )
	
	, invoice_date( Date )
	
	, trace( [ `Invoice Date`, invoice_date ] )

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
	
	, generic_horizontal_details( [ read_ahead( [ dummy(s1), newline ] ), order_number_x, [ begin, q([alpha,dec],0,8), q(alpha,1,1), q(dec,1,1), q([alpha,dec],0,8), end ]
	
		, [ q10( [ `-`, `R`, delivery_note_reference( `by_rule` ) ] ), newline ] ] )
		
	, q(0,15,line)
	
	, generic_vertical_details( [ [ `Project`, `Number` ], `Project`, end, order_number_y, s1 ] )

	, check( order_number_x = Ord_X )
	
	, check( order_number_y = Ord_Y )
	
	, check( strcat_list( [ Ord_X, `-`, Ord_Y ], Order ) )
	
	, order_number( Order )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Contact`, `:` ], delivery_contact, s1 ] )
	  
	, q10( generic_horizontal_details( [ nearest( delivery_contact(start), 10, 10 ), delivery_ddi, s1 ] ) )

] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ at_start, read_ahead( [ `Personne`, `Responsable` ] ) ], dummy, s1 ] )
	
	, up, up
	
	, generic_horizontal_details( [ buyer_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_email, [ buyer_email( From ) ] ):- i_mail( from, From ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
		
			, line_continuation_line
			
			, line

		] )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Qty`, `Item`, tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`COMMENTAIRES`

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, or( [ [ test( trash )
	
			, check( line_net_amount = Net )
			
			, delivery_charge( Net )
			
		]
		
		, count_rule
		
	] )
	
	, clear( trash )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, `!`
	
	, or( [ generic_item( [ line_item, s1, tab ] )
	
		, [ line_item( `Missing` ), tab ]
		
	] )
	
	, act(d), tab, q10( grp(d) )
	
	, q10( [ read_ahead( `Majoration` ), set( trash ), line_type( `Trash` ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================
   
	  append( line_descr(s1), ` `, `` )
	
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
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ `TOTAL`, total_invoice, d, [ `$`, newline ] ] )
	
	, check( total_invoice = Total )
	
	, total_net( Total )	
	
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

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line), get_total_header_line
	
	, total_net( `0` )
	
	, qn0( or( [ add_up_totals, line ] ) )
	
	, check( total_invoice = Total )
	
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

%=======================================================================
i_line_rule( get_total_header_line, [
%=======================================================================

	q0n(anything), tab, `Unit`, `Price`, tab
	
	, total_hook(w), newline 
	
] ).

%=======================================================================
i_line_rule( add_up_totals, [
%=======================================================================

	nearest( total_hook(start), 10, 10 )
	
	, generic_item( [ line_total, d, newline ] )
	
	, check( sys_calculate_str_add( total_net, line_total, Running ) )
	
	, total_net( Running )
	
	, total_invoice( Running )
	
] ).