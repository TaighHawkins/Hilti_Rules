%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US TRUE VALUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_true_value, `07 April 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X, X ).

i_user_field( invoice, delivery_id, `Delivery ID` ).

%================================================================
%		Fleet Orders
%================================================================

i_user_field( line, zzfmcontracttype, `ZZF contract type` ).
i_user_field( line, zzfminvnr, `ZZF minvnr` ).

i_op_param( xml_empty_tags( Fleet_U ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, fleet_thing( Fleet )
	, sys_string_atom( Fleet, Atom )
	, result( _, LID, Atom, Answer )
	, string_to_upper( Fleet, Fleet_U )
.

fleet_thing( `zzfmcontracttype` ).
fleet_thing( `zzfminvnr` ).
%================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_location

	, get_order_date
	
	, get_order_number
	
	, get_due_date
	
	, get_buyer_contact
	
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

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11249011` ) ]    %TEST
	    , suppliers_code_for_buyer( `10810300` )                      %PROD
	]) ]

	, agent_name(`US_ADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `01` )
	
	, cost_centre( `Saver 2-4 day Ground` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	  q(0,30,line), read_ahead( generic_horizontal_details( [ [ `Member` ], member_number_x, sf, `-` ] ) )
	  
	, generic_horizontal_details( [ `-`, check_digit, [ begin, q(dec,1,1), end ] ] )

	, check( i_user_check( manipulate_the_member_number, member_number_x, Mem ) )
	
	, check( check_digit = Digit )

	, check( strcat_list( [ Mem, `-`, Digit ], Id ) )

	, delivery_id( Id )
	
	, check( strcat_list( [ `TV `, Mem, `-`, Digit ], Loc ) )
	
	, delivery_location( Loc )
	
	, trace( [ `Delivery Location`, delivery_location ] )
	  
] ).

%=======================================================================
i_user_check( manipulate_the_member_number, Mem_X, Mem )
%------------------------------------------------------------------
:-
%=======================================================================

	trace( in( Mem_X ) )
	
	, ( regexp_match( `^([\\d]{4})$`, Mem_X, _ )
		->	Mem = Mem_X
		
		;	regexp_match( `^([\\d]{1,3})$`, Mem_X, _ )
			, string_pad_left( Mem_X, 4, `0`, Mem )
			
		;	regexp_match( `^([\\d]{5,})$`, Mem_X, _ )
			, sys_string_length( Mem_X, Mem_Length )
			, sys_calculate( Mem_Length_Less_Four, Mem_Length - 4 )
			, q_sys_sub_string( Mem_X, 1, Mem_Length_Less_Four, Mem_Zeros )
			, regexp_match( `^([0]{1,})$`, Mem_Zeros, _ )
			, extract_pattern_from_back( Mem_X, Mem, [ dec, dec, dec, dec ] )
			
		;	regexp_match(`^([\\d]{5,})$`, Mem_X, _ )
			, Mem = Mem_X
			
	)
.

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,30,line), generic_vertical_details( [ [ `Credit`, `Authorization`, `#`, `:` ], `Credit`, credit_auth, s1, tab ] )
	  
	, with( invoice, delivery_id, Loc )
	
	, check( credit_auth = Cred )
	
	, check( strcat_list( [ Loc, `.`, Cred ], Ord ) )

	, order_number( Ord )
	
	, trace( [ `Order Number`, order_number ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Shipping`, `Date`, `:` ] ] )
	  
	, generic_horizontal_details( [ nearest_word( generic_hook(start), 5,5), due_date, date ] )

] ).


%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,30,line), generic_vertical_details( [ [ `Order`, `Contact`, `:`, newline ], `Order`, buyer_contact_x, s1, newline ] )

	, check( string_to_upper( buyer_contact_x, Con_u ) )

	, or( [ [ check( not( q_sys_sub_string( Con_u, _, _, `ORDER CONTACT` ) ) )
	
			, buyer_contact( Con_u )
	
			, q10([ q(0, 3, line), generic_vertical_details( [ [ `Order`, `Contact`, `Email` ], `Order`, buyer_email, s1, newline ] ) ])
	 
		]
		
		, [ buyer_contact( `LINDSEY WILLIAMS` )
		
			, buyer_email( `Lindsey.Williams@hilti.com` )
			
		]
		
	] )


] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line)
	  
	, read_ahead( generic_horizontal_details( [ [ `Total`, `:` ], total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Total`, `:` ], total_invoice, d, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
i_line_rule_cut( line_header_line, [ `MODEL`, `#`, q10( tab ), `Description`, q10(tab), each(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  or( [ [ or( [ generic_item( [ line_item, [ q(alpha("f"),1,1), begin, q(dec,4,10), end ], q10( tab ) ] )
	  
				, generic_item( [ line_item, [ begin, q(dec,4,10), end, q(alpha("f"),1,1) ], q10( tab ) ] )
				
			] )
	  
			, zzfmcontracttype( `ZFCP` )
			
			, with( invoice, delivery_id, Loc )
			
			, zzfminvnr( Loc )
			
		]
	  
		, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], q10( tab ) ] )
		
			, with( invoice, due_date, Due )
			
			, line_original_order_date( Due )
			
		]

	] )

	, generic_item( [ line_descr, s, q10( tab ) ] )
	
	, check( line_descr(end) < each(start) )
	
	, generic_item( [ line_unit_amount_x, d, tab ] )

	, generic_item( [ pack, d, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )

	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).