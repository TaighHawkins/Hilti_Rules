%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - THIESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( thiess, `14 October 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_delivery_address
	
	, get_fixed_variables

	, get_buyer_contact
	
	, get_buyer_ddi

	, get_missing_contact_details

	, get_order_number
	
	, get_order_date
	
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

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,10,line), delivery_header_line

	, q01(line), q10( delivery_thing_line( [ delivery_dept ] ) )
	
	, q(0,2, delivery_thing_line( [ delivery_address_line ] ) )
	
	, delivery_thing_line( [ delivery_street ] )

	, delivery_city_postcode_line
	
	, check_variation

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), `Deliver`, `To`, generic_item( [ delivery_party, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )

	, generic_item( [ Variable, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_city_postcode_line, [ 
%=======================================================================
	
	  nearest( delivery_party(start), 10, 10 )

	, delivery_city(sf)
	
	, delivery_state(w)

	, delivery_postcode(f( [ begin, q(dec,4,5), end ] ) )
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_state, delivery_city ] )
	  
] ).

%=======================================================================
i_rule_cut( check_variation, [ 
%=======================================================================
	
	check( delivery_state = State )
	, check( strcat_list( [ `AUTHIESS`, State ], BCFB ) )
	
	, or( [ [ check( delivery_state = `QLD` )
			, set( variation, `11125503` )
			, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10483878` ) ]
				, suppliers_code_for_buyer( `11125503` )
			] )
		]
		
		, [ check( delivery_state = `WA` )
			, set( variation, `11125486` )
			, buyers_code_for_buyer( BCFB )
		]
		
		, [ check( delivery_state = `NSW` )
			, set( variation, `11125483` )
			, buyers_code_for_buyer( BCFB )
			, delivery_note_reference( BCFB )
			, set( delivery_note_ref_no_failure )
			, buyer_contact( `Phil Nguyen` )
			, buyer_ddi( `0427749190` )
			, buyer_fax( `0293314264` )
			, buyer_email( `pnguyen@thiess.com.au` )
			, delivery_contact( `Phil Nguyen` )
			, delivery_ddi( `0427749190` )
			, delivery_fax( `0293314264` )
			, delivery_email( `pnguyen@thiess.com.au` )
			, remove( delivery_party )
			, remove( delivery_dept )
			, remove( delivery_address_line )
			, remove( delivery_street )
			, remove( delivery_city )
			, remove( delivery_state )
			, remove( delivery_postcode )
		]
	] )
	
	, test( variation, Var )
	, trace( [ `Variation`, Var ] )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Purchase`, `Order`, `No`, `.` ], order_number, s1 ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Date` ], invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ or( [ tab, at_start ] ), name_headers ], buyer_contact_x, sf, or( [ `or`, gen_eof ] ) ] )
	 
	, check( buyer_contact_x(y) > -150 )
	
	, check( i_user_check( reverse_names, buyer_contact_x, Con ) )

	, buyer_contact( Con )
	
	, delivery_contact( Con )
	
] ):- grammar_set( variation, `11125503` ).

%=======================================================================
i_rule( name_headers, [ 
%=======================================================================

	or( [ [ `Contact`, `Name`, or( [ [ `No`, `1` ], `No1` ] ) ]
	
		, `Name`
	
		, `Att`
		
		, `Attn`
		
		, `Contact`
	
	] )
	
] ).

%=======================================================================
i_user_check( reverse_names, Names_In, Names_Out ):- 
%=======================================================================
  
	  strip_string2_from_string1( Names_In, `,`, Names_In_Strip )  
	, sys_string_split( Names_In_Strip, ` `, [ Surname | Names_Rev ] ) 
	, sys_reverse( Names_Rev, Names )

	, wordcat( [ Surname | Names ], Names_Out )
.

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ or( [ tab, at_start ] ), phone_headers ], buyer_ddi, s1, [ tab, some(date) ] ] )
	  
	, check( buyer_ddi = DDI )
	
	, delivery_ddi( DDI )
	
] ):- grammar_set( variation, `11125503` ).

%=======================================================================
i_rule( phone_headers, [ 
%=======================================================================

	or( [ [ `Contact`, `Number`, or( [ [ `No`, `1` ], `No1` ] ) ]
		
		, `Phone`
	
		, `Ph`

	] )
	
] ).

%=======================================================================
i_rule( get_missing_contact_details, [ 
%=======================================================================

	without( buyer_contact )
	, buyer_contact( `David X McCormack` )
	, delivery_contact( `David X McCormack` )
	, buyer_fax( `0289168364` )
	, delivery_fax( `0289168364` )
	, buyer_email( `dxmccormack@thiess.com.au` )
	, delivery_email( `dxmccormack@thiess.com.au` )

] ):- grammar_set( variation, `11125503` ).

%=======================================================================
i_rule( get_totals, [ qn0(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  q0n(anything), `GST`, `EXCL`, `TOTAL`, `(`, `AUD`, `)`, tab
	  
	, read_ahead( [ generic_item( [ total_net, d, newline ] ) ] )
	
	, generic_item( [ total_invoice, d, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_invoice_line
		
			, line_instructions_line

			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Delivery`, tab, `(`, `Exclusive` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `This`, `Order`, `Is` ], [ `Page`, `:` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   

	  generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, sf, q10( tab ) ] )

	, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q10( dummy(s1) ), tab ] ] )
	
		, line_item( `Missing` )
	] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item( [ line_unit_amount_x, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_instructions_line, [
%=======================================================================
   

	  or( [ [ with( shipping_instructions )
	  
			, append( shipping_instructions(s1), ` `, `` )

			, trace( [ `Appended instructions` ] )
			
		]
	  
		, [ without( shipping_instructions )
		
			, generic_item( [ shipping_instructions, s1 ] ) 
			
		]
		
	] ), tab
	
	, some(date), newline

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).