%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US FABCON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_fabcon, `18 June 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_address

	, get_emails

	, get_order_date
	
	, get_order_number
	
	, check_revision
	
	, check_repair_or_calibration_order

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

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11232646` ) ]    %TEST
	    , suppliers_code_for_buyer( `10769760` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, delivery_party( `FABCON INC` )
	
	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,10,line), delivery_header_line( [ Left ] )
	  
	, q(0,2,line)
	  
	, delivery_street_line( 1, Left, 500 )
	  
	, delivery_city_state_postcode_line( 1, Left, 500 )
	  
] ).

%=======================================================================
i_line_rule( delivery_header_line( [ Left ] ), [ 
%=======================================================================

	  q0n(anything)
	  
	, read_ahead( [ `Delivery`, `Address` ] ), hook(w)
	
	, check( hook(start) = Start )
	
	, check( sys_calculate( Left, Start - 5 ) )
	
	,  trace( [ `found header` ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ generic_item( [ delivery_street, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	  generic_item( [ delivery_city, sf, `,` ] )
	
	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, q10( append( delivery_postcode(f( [ begin, q(other("-"),1,1), q(dec,4,4), end ] ) ), ``, `` ) )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	NO-PROCESS RULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_revision, [ 
%=======================================================================

	  q(0,4,line), generic_vertical_details( [ [ `Revision` ], `Revision`, revision, d, tab ] )
	  
	, check( revision = Rev )
	
	, or( [ check( q_sys_sub_string( Rev, _, _, `0` ) )
	
		, [ delivery_note_reference( `by rule` ) ]
		
	] )
	  
] ).

%=======================================================================
i_rule( check_repair_or_calibration_order, [ 
%=======================================================================

	  q0n(line), line_header_line
	  
	, q(0,20,line), check_repair_or_calibration_line
	  
] ).

%=======================================================================
i_line_rule( check_repair_or_calibration_line, [ 
%=======================================================================

	  q0n(anything)
	  
	, or( [ `repair`, `calibration`, `calibrate` ] )
	
	, delivery_note_reference( `by rule` )
	
	, trace( [ `Repair order` ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,7,line), generic_vertical_details( [ [ `Purchase`, `Order` ], `Purchase`, order_number, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  buyer_contact( Names )
	  
	, delivery_contact( Names )
	
	, buyer_email( From )
	
	, delivery_email( From )
	
	, trace( [ `emails`, buyer_email ] )
	 
] )
:-
	i_mail( from, From )
	, sys_string_split( From, `@`, [ Name_Dot | _ ] )
	, string_string_replace( Name_Dot, `.`, ` `, Names )
.

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,7,line), generic_vertical_details( [ [ `Our`, `Order`, `Date` ], `Our`, invoice_date, date, tab ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line)
	  
	, read_ahead( generic_horizontal_details( [ [ `Total`, `Amount`, tab, `(`, `USD`, `)` ], 250, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Total`, `Amount`, tab, `(`, `USD`, `)` ], 250, total_invoice, d, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_section_end_line ).
%=======================================================================
i_line_rule_cut( line_section_end_line, [ `Postal`, `Address` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
			
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Tech`,`Coordinator`, tab, `Supplier`, q0n(anything), read_ahead( `Dock` ), dock(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total`, `Tax`, `Amount` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_item_and_descr_line
	
	, or( [ [ peek_fails( test( missing_item ) ), q10( [ line_continuation_line ] ) ]
	
		, [ test( missing_item ), missing_item_line ]
		
		, [ test( missing_item ), line_continuation_line, missing_item_line ]
		
		, [ test( missing_item ), line_item( `Missing` ), q10( line_continuation_line ) ]
		
	] )
	
	, clear( missing_item )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
		, generic_item( [ line_item, s1, tab ] )
		
		, set( missing_item ) 
		
	] )
	
	, read_ahead( dummy(d) )
	
	, check( dummy(end) < dock(start) )
	
	, or( [ [ generic_item( [ line_quantity, d, tab ] )
	
			, generic_item( [ some_qty, d ] )
			
		]
		
		, [ generic_item( [ line_quantity, d ] ) ]
		
	] )

	, generic_item( [ some_uom, [ begin, q(alpha,1,5), end ], q10( tab ) ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ some_date, date, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_and_descr_line, [
%=======================================================================
   
	  generic_item( [ some_item, d, tab ] )
	  
	, q10( [ generic_item( [ line_item_for_buyer, s1, tab ] )

		, check( line_item_for_buyer(end) < -300 )
		
	] )
	
	, or( [ [ peek_fails( [ dummy(d), tab ] ), generic_item( [ line_descr, s1, tab ] ) ]
	
		, [ check( line_item_for_buyer = Item )
		
			, line_descr( Item )
			
		]
		
	] )
	
	, q(2,3,generic_item( [ some_qty, d, tab ] ) )
	
	, generic_item( [ some_value, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( missing_item_line, [
%=======================================================================
   
	  q10( [ `Item`, `#` ] )
	  
	, q0n(word), generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
] ).
