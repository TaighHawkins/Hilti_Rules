%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KAMPER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_kamper, `15 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_delivery_date

	, get_contacts
	
	, get_delivery_address

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_order_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	, set( delivery_note_ref_no_failure )
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `11205957` ) ]
		, suppliers_code_for_buyer( `20556799` )
	] )
	
	, sender_name( `Kamper Handwerk + Bau GmbH` )
	
	, buyer_email( `office@kamper.at` )
	, delivery_email( `office@kamper.at` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	q(0,30,line), generic_horizontal_details( [ [ `Nr`, `.`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	q(0,30,line), generic_horizontal_details( [ [ `Nr`, `.`, `:`, qn0(anything), tab ], invoice_date_x, s1 ] )
	  
	, check( i_user_check( clean_up_date, invoice_date_x, Date ) )
	, invoice_date( Date )

] ).

%=======================================================================
i_user_check( clean_up_date, DateIn, DateOut ) 
%=======================================================================
:-
	string_to_lower( DateIn, DateInL ),
	date_lookup( Month, MonthNum ),
	q_sys_sub_string( DateInL, _, _, Month ),
	strcat_list( [ `/`, MonthNum, `/` ], MonthSlash ),
	string_string_replace( DateInL, Month, MonthSlash, DateNum ),
	strip_string2_from_string1( DateNum, `. `, DateOut )
.

date_lookup( `januar`, `01` ).
date_lookup( `jänner`, `01` ).
date_lookup( `februar`, `02` ).
date_lookup( `märz`, `03` ).
date_lookup( `april`, `04` ).
date_lookup( `mai`, `05` ).
date_lookup( `juni`, `06` ).
date_lookup( `juli`, `07` ).
date_lookup( `august`, `08` ).
date_lookup( `september`, `09` ).
date_lookup( `oktober`, `10` ).
date_lookup( `november`, `11` ).
date_lookup( `dezember`, `12` ).

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================	  
	  
	q(0,20,line), generic_horizontal_details( [ [ `Liefern`, `bis`, `spätestens`, `:` ], delivery_date, date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Ansprechperson`, `:` ], buyer_contact, sf, or( [ `,`, newline ] ) ] )
	
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	q(0,30,line)

	, generic_horizontal_details( [ [ at_start, `Liefern`, `an`, `:` ], delivery_party, s1 ] )

	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
	
	, generic_item( [ delivery_city, sf, `,` ] )
	
	, generic_item( [ delivery_street, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_totals, [
%=======================================================================

	or( [ [ q0n(line), generic_horizontal_details( [ [ `Total`, `EUR`, `ohne`, dummy(s1) ], 250, total_net, d ] ) ]

		, [ set( no_total_validation )
			, total_net( `0` )
		]
	] )
	
	, check( total_net = Net )
	, total_invoice( Net )
	
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
	 
	, q0n( 
		or( [ line_invoice_rule
			, line
		] )
	)
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Art`, `.`, `Nr`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Total`, `EUR` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_position_line
	
	, or( [ [ line_values_line
	
			, q10( [ with( invoice, delivery_date, Date )
				, line_original_order_date( Date )
			] )
		]
		
		, [ force_result( `defect` ), force_sub_result( `missed_line` ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_position_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	, generic_item( [ line_quantity_uom_code, w, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	 or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ), line_item( `Missing` ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, or( [ [ generic_item_cut( [ line_unit_amount, d, tab ] )
	
			, q10( [ `-`, generic_item_cut( [ line_percent_discount, d, tab ] ) ] )
			
			, generic_item_cut( [ line_net_amount, d, newline ] )
		]
		
		, [ `.`, `.`, `.`, `.`, line_net_amount( `0` ) ]
		
	] )

] ).