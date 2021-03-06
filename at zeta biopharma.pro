%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ZETA BIOPHARMA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( zeta_biopharma, `27 January 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details

	, get_buyer_ddi
	
	, get_buyer_contact

	, get_order_date

	, get_order_number

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ q0n(line), invoice_total_line]
	
	, get_invoice_lines

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  without( buyer_party )
	
	, set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `16663897` ) ]
		, suppliers_code_for_buyer( `16663897` )
	] )
	
	, sender_name( `Zeta Biopharma GmbH` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Unser`, `Zeichen`, `:` ], buyer_contact_x, s1, newline ] )
	  
	, check( i_user_check( reverse_names, buyer_contact_x, Con ) )

	, buyer_contact( Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_user_check( reverse_names, Names_In, Names_Out ):- 
%=======================================================================
  
	  strip_string2_from_string1( Names_In, `,`, Names_In_Strip )  
	, sys_string_split( Names_In_Strip, ` `, [ Surname | Names_Rev ] ) 
	, sys_reverse( Names_Rev, Names )

	, sys_append( Names, [ Surname ], NewNames )
	, wordcat( NewNames, Names_Out )
.


%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Tel`, `.`, `:` ], buyer_ddi_x, s1, newline ] )
	  
	, check( string_string_replace( buyer_ddi_x, `+43`, `0`, DDI ) )

	, buyer_ddi( DDI )
	, delivery_ddi( DDI )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ `Lieferadresse` ] )
	  
	, check( generic_hook(start) = Start )
	
	, q(5,0, gen_line_nothing_here( [ Start, 10, 10 ] ) )
	, generic_horizontal_details_cut( [ nearest( Start, 10, 10 ), delivery_party, s1 ] )
	
	, q10( [ q(5,0, gen_line_nothing_here( [ Start, 10, 10 ] ) )
		, generic_horizontal_details_cut( [ nearest( Start, 10, 10 ), delivery_dept, s1 ] ) 
	] )
	
	, q01( [ q(1,2
		, [ q(5,0, gen_line_nothing_here( [ Start, 10, 10 ] ) )
			, generic_horizontal_details_cut( [ nearest( Start, 10, 10 ), delivery_address_line, s1 ] )
		] )
		
		, q01( line )
	] )
	
	, q(5,0, gen_line_nothing_here( [ Start, 10, 10 ] ) )
	, generic_horizontal_details_cut( [ nearest( Start, 10, 10 ), delivery_street, s1 ] )
	
	, q(5,0, gen_line_nothing_here( [ Start, 10, 10 ] ) )
	, delivery_postcode_city_line( [ Start ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_postcode_city_line( [ Start ] ), [
%=======================================================================

	  nearest( Start, 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Bestellung`, `Nr`, `.`, `:` ], order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ `Datum`, `:` ], invoice_date_x, s1 ] )
	
	, check( i_user_check( clean_up_date, invoice_date_x, Date ) )
	, invoice_date( Date )
	, trace( [ `Invoice Date`, invoice_date ] )

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	  `Total`, `EUR`, q10( [ `ohne`, `MwS` ] ), tab

	, read_ahead(total_invoice(d))

	, total_net(d)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		or( [ line_invoice_rule
		
			, line_defect_line

			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, q10( tab ), `Art`, `-`, `Nr`, `.`, tab, header(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Total`, `EUR` ]
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ [ q(1,2,line_continuation_line)
	
			, line_item_line
			
		]
		
		, line_item( `Missing` )
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date ] )

	, q10( [ tab, generic_item_cut( [ line_unit_amount, d, tab ] )
	
		, q01( generic_item( [ line_percent_discount, d, tab ] ) )

		, generic_item_cut( [ line_net_amount, d ] )
		
	] )
	
	, newline

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_defect_line, [ q0n(anything), some(date), force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================

