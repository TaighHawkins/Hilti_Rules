%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US AFL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_afl_rules, `21 February 2014` ).

i_date_format( 'm/d/y' ).
i_format_postcode( X, X ).

i_user_field( invoice, possible_delivery_state, `proposed delivery state (need to match with ups code)` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 set( purchase_order )

	, left_margin_section

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, currency( `6000` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10478573` ) ]    %TEST
	    , suppliers_code_for_buyer( `10791174` )                      %PROD
	]) ]


%	, suppliers_code_for_buyer( `10791174` )   %PROD
%	, suppliers_code_for_buyer( `10478573` )   %TEST

	, type_of_supply(`N4`)
	, cost_centre(`HNA- CustAcct`)

%	, customer_comments( `Customer Comments` )
	, customer_comments( `` )

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	, get_customer_comments_and_shipping_instructions

	, get_delivery_details

%	, get_delivery_location ?????

	, get_order_number

	, get_order_date

	, get_buyer_details

	, get_buyer_contact

	, verify_delivery_state_and_ups_code

	, get_invoice_lines

	, [ qn0(line), buyer_start_line, q0n(line), invoice_total_line ]

	, gen_get_from_cache_at_end

	, gen_set_cache
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEFT MARGIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
% this must be done as the first section to ensure it runs first

i_section( left_margin_section, [ left_margin_line ] ).

%=======================================================================

%=======================================================================
i_line_rule( left_margin_line, [
%=======================================================================

	read_ahead( actual_left_margin )
	
	, `harsco`

	, check( i_user_check( gen_add, actual_left_margin( start ), 452, LM ) )

	, set( left_margin, LM )

	, trace( [`left margin`, LM] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS AND SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments_and_shipping_instructions, [
%=======================================================================

	q0n(line)

	, cc_and_si_head_line( [ START ] )

	, qn0( gen_line_nothing_here( [ 30, 20, 20 ] ) )

	, cc_and_si_data_line( [ START ] )
] ).

%=======================================================================
i_line_rule_cut( cc_and_si_head_line( [ START ] ), [
%=======================================================================

	q0n( anything )

	, read_ahead( dummy(w1) )

	, `Mark`, `All`, `Packages`, `&`, `Documents`

	, check( i_user_check( gen_same, dummy(start), START ) )
] ).

%=======================================================================
i_line_rule_cut( cc_and_si_data_line( [ START ] ), [
%=======================================================================

	nearest( START, 20, 20 )

	, read_ahead( customer_comments(s1) )

	, shipping_instructions( s1 )

	, trace( [ `shipping instructions`, shipping_instructions ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q0n( line )

	, ship_to_line

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), -140, 10, 10 ) )

	, gen1_address_details( [ delivery_left_margin, line, delivery_party1, delivery_contact1,
					delivery_street, delivery_address_line, delivery_city1, delivery_state1, postcode( delivery_postcode, delivery_postcode_searcher ),
					delivery_end_line ] )

	, trace([`delivery street`, delivery_street])

	, delivery_party( `AFL Global` )
	
	, delivery_dept(``)
] ).

%=======================================================================
i_line_rule( ship_to_line, [
%=======================================================================

	q0n(anything)

	, `ship`, `-`, `to`
] ).

%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	nearest_word( LEFT_MARGIN_START, LEFT_TOLERANCE, RIGHT_TOLERANCE )

	, `(`, `P`, `)`, ignore_delivery_ddi(s1), tab

	, `(`, `F`, `)`, ignore_delivery_fax(s1)
])

:-
	i_user_data( address_margin( [ delivery_left_margin, LEFT_MARGIN_START, LEFT_TOLERANCE, RIGHT_TOLERANCE ] ) )

. %end%

%=======================================================================
i_rule( delivery_postcode_searcher, [
%=======================================================================

	or( [ [ delivery_city(s), `,` ], delivery_city(s) ] )

	, possible_delivery_state( f( [ begin, q(alpha,2,2), end ] ) )

	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )

	, q10( [

		`-`

		, append( delivery_postcode( `-` ), ``, `` )

		, append( delivery_postcode( f( [ begin, q(dec,4,4), end ] ) ) )
	] )
] ).

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	q0n(line)

	, delivery_start_line

	, q(0, 6, line)

	, delivery_location_line

]).

%=======================================================================
i_line_rule( delivery_location_line, [ 
%=======================================================================

	q0n(anything)

	, `GB`

	, delivery_location(f([begin, q(dec, 4, 6 ), end ]))

	, trace( [ `delivery location`, delivery_location] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [
%=======================================================================

	gen1_address_details( [ buyer_left_margin, buyer_start_line, buyer_party1, not_the_buyer_contact,
					buyer_street, buyer_address_line, buyer_city1, buyer_state1, postcode( buyer_postcode, buyer_postcode_searcher ),
					buyer_end_line ] )
	
	, buyer_dept(``)
] ).

%=======================================================================
i_line_rule( buyer_start_line, [
%=======================================================================

	q0n(anything),

	read_ahead( buyer_left_margin ),

	`OPIREMIT`, newline,

	check( i_user_check( gen1_store_address_margin( buyer_left_margin ), buyer_left_margin(start), 10, 10 ) )
] ).

%=======================================================================
i_line_rule( buyer_end_line, [ 
%=======================================================================

	`(`, `P`, `)`

	, trace( [ buyer_ddi, buyer_fax ] )
]).

%=======================================================================
i_rule( buyer_postcode_searcher, [
%=======================================================================

	or( [ [ buyer_city(s), `,` ], buyer_city(s) ] )

	, buyer_state( f( [ begin, q(alpha,2,2), end ] ) )

	, buyer_postcode( f( [ begin, q(dec,5,5), end ] ) )

	, q10( [

		`-`

		, append( buyer_postcode( `-` ), ``, `` )

		, append( buyer_postcode( f( [ begin, q(dec,4,4), end ] ) ) )
	] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	q0n( line )

	, buyer_contact_start_line

	, qn0( gen_line_nothing_here( [ -470, 20, 20 ] ) )

	, buyer_contact_line

	, qn0( gen_line_nothing_here( [ -470, 20, 20 ] ) )

	, buyer_phone_line

	, qn0( gen_line_nothing_here( [ -470, 20, 20 ] ) )

	, buyer_email_line
] ).

%=======================================================================
i_line_rule_cut( buyer_contact_start_line, [ `Please`, `confirm`, `with`, `buyer` ] ).
%=======================================================================

%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	lower_buyer_contact(s1)

	, check( i_user_check( gen_string_to_upper, lower_buyer_contact, BU  ) ), buyer_contact( BU )

	, trace( [ `buyer_contact`, buyer_contact ] )
] ).

%=======================================================================
i_line_rule( buyer_phone_line, [
%=======================================================================

	`(`, `P`, `)`, buyer_ddi(s1), tab

	, trace( [ `buyer_ddi`, buyer_ddi ] )

	, `(`, `F`, `)`, buyer_fax(s1)

	, trace( [ `buyer_fax`, buyer_fax ] )
] ).

%=======================================================================
i_line_rule( buyer_email_line, [
%=======================================================================

	buyer_email(s1)

	, trace( [ `buyer_email`, buyer_email ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q0n(line)

	, or( [ order_date_line, [ order_date_header_line, order_date_on_next_line ] ] )
] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	q0n(anything), `date`

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date] )
]).

%=======================================================================
i_line_rule( order_date_header_line, [ 
%=======================================================================

	q0n(anything), `date`

	, newline
]).

%=======================================================================
i_line_rule( order_date_on_next_line, [ 
%=======================================================================

	q0n(anything)

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date] )
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERIFY DELIVERY STATE AND UPS CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( verify_delivery_state_and_ups_code, [
%=======================================================================

	with( invoice, possible_delivery_state, STATE )

	, q0n(line)

	, vendor_name_line

	, vendor_number_line( [ NUMBER ] )

	, q10( with( invoice, delivery_city, CITY ) )

	, check( i_user_check( lookup_ups_code, NUMBER, CITY, STATE, CODE ) )

	, buyers_code_for_location( CODE )

	, delivery_state( STATE )

	, trace( [ `looked up`, STATE, CODE ] )
] ).

%=======================================================================
i_rule( verify_delivery_state_and_ups_code, [
%=======================================================================

	delivery_state( `` )

	, buyers_code_for_location( `` )
] ).

%=======================================================================
i_line_rule( vendor_name_line, [ `Vendor`, tab ] ).
%=======================================================================

%=======================================================================
i_line_rule( vendor_number_line( [ NUMBER ] ), [ dummy(s1), tab, check( i_user_check( gen_same, dummy, NUMBER ) ) ] ).
%=======================================================================

%=======================================================================
i_user_check( lookup_ups_code, NUMBER, READ_CITY, STATE, CODE )
%-----------------------------------------------------------------------
:-
%=======================================================================

	ups_table( VEN, CODE, _, TABLE_CITY, STATE, _ )

	, q_sys_sub_string( NUMBER, 1, _, VEN )

	, (	q_sys_var( READ_CITY )

		;

		string_to_lower( READ_CITY, LOWER_READ_CITY )

		, string_to_lower( TABLE_CITY, LOWER_TABLE_CITY )

		, q_sys_comp( LOWER_READ_CITY = LOWER_TABLE_CITY )
	)

. %end%

ups_table( `0`,`07V195`,`212 Total Solutions Way`,`Alabaster`,`AL`,`35007`).
ups_table( `0`,`9V36W1`,`44 Buck Shoals Road`,`Arden`,`NC`,`28704`).
ups_table( `0`,`07V195`,`457 Highlandia Drive`,`Baton Rouge`,`LA`,`70810`).
ups_table( `0`,`6V5527`,`706 Cahaba Valley Circle`,`Birmingham`,`AL`,`35124`).
ups_table( `0`,`7Y786V`,`2207 Kimball Rd. SE`,`Canton`,`OH`,`44707`).
ups_table( `0`,`8E25A3`,`5397 Orange Drive Suite #102`,`Davie`,`FL`,`33314`).
ups_table( `0`,`91684E`,`2222 Northmont Parkway`,`Duluth`,`GA`,`30096`).
ups_table( `0`,`46A34R`,`297 Tucapau Road`,`Duncan`,`SC`,`29334`).
ups_table( `0`,`7646VR`,`408-B Gallimore Dairy Road`,`Greensboro`,`NC`,`27409`).
ups_table( `0`,`XX1647`,`109-A Western Lane`,`Irmo`,`SC`,`29063`).
ups_table( `0`,`9V359W`,`7255 Salisbury Road`,`Jacksonville`,`FL`,`32256`).
ups_table( `0`,`R438Y9`,`2159 Watterson Trail`,`Louisville`,`KY`,`40299`).
ups_table( `0`,`28678E`,`2807 Gray Fox Road`,`Monroe`,`NC`,`28110`).
ups_table( `0`,`7646Y4`,`100 North Rose Street`,`Mount Clemens`,`MI`,`48043`).
ups_table( `0`,`9V36X7`,`22 Stanley Street`,`Nashville`,`TN`,`37210`).
ups_table( `0`,`083TT4`,`9561 Satellite Boulevard`,`Orlando`,`FL`,`32837`).
ups_table( `0`,`9V360E`,`6156 State Route 54`,`Philpot`,`KY`,`42366`).
ups_table( `0`,`0497FA`,`16350 Downey Ave`,`Paramount`,`CA`,`90723`).
ups_table( `0`,`9V361X`,`3039 N Andrews Ave Ext`,`Pompano Beach`,`FL`,`33064`).
ups_table( `0`,`W198Y1`,`1210 Corporation Parkway`,`Raleigh`,`NC`,`27610`).
ups_table( `0`,`7Y786V`,`6911-6913 Americana Parkway`,`Reynoldsburg`,`OH`,`43068`).
ups_table( `0`,`07V224`,`501 W 61st Street`,`Shreveport`,`LA`,`71106`).
ups_table( `0`,`XX7836`,`8000 Safari Drive`,`Smryna`,`TN`,`37167`).
ups_table( `0`,`32176W`,`1205 Icehouse`,`Sparks`,`NV`,`89431`).
ups_table( `0`,`7WX705`,`1900 Fortune Drive`,`Winchester`,`KY`,`40391`).
ups_table( `1`,`7646VX`,`1420 Bigley Ave`,`Charleston`,`WV`,`25302`).
ups_table( `1`,`A771R9`,`825 Greenbrier Circle`,`Chesapeake`,`VA`,`23320`).
ups_table( `1`,`7646Y2`,`6605 Selnick Drive`,`Elkridge`,`MD`,`21075`).
ups_table( `1`,`A1W092`,`530 McCormick Drive`,`Glen Burnie`,`MD`,`21061`).
ups_table( `1`,`9464AR`,`3499 State Route 79`,`Harpursville`,`NY`,`13787`).
ups_table( `1`,`9V363W`,`44 Railroad Street`,`Huntington Station`,`NY`,`11746`).
ups_table( `1`,`V3V837`,`6 Water Street`,`Manhattan`,`NY`,`10004`).
ups_table( `1`,`40A0E6`,`510 Broadhallow Road`,`Melville`,`NY`,`11747`).
ups_table( `1`,`A0W905`,`605 Interchange Boulevard`,`Newark`,`DE`,`19711`).
ups_table( `1`,`9V365F`,`430 Island Lane`,`West Haven`,`CT`,`06516`).
ups_table( `35`,`8E259A`,`5068 W. Plano Parkway`,`Plano`,`TX`,`75093`).
ups_table( `40`,`8E249E`,`706 Cahaba Valley Circle`,`Birmingham`,`AL`,`35124`).
ups_table( `40`,`931AX5`,`9926 Brook Road`,`Glen Allen`,`VA`,`23059`).
ups_table( `40`,`V8138F`,`1210 Corporation Parkway`,`Raleigh`,`NC`,`27610`).
ups_table( `40`,`93X0X8`,`2807 Gray Fox Road`,`Monroe`,`NC`,`28110`).
ups_table( ``,`8E25Y3`,`21161 Hwy 36`,`Covington`,`LA`,`70433`).
ups_table( ``,`8E25R4`,`102 Business Park Drive`,`Ridgeland`,`MS`,`39157`).
ups_table( ``,`2X7141`,`2555 3rd Street Suite 108`,`Sacramento`,`CA`,`95826`).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q0n(line)

	, order_number_line

] ).

%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================


	q0n(anything), `purchase`, `order`

	, q10(tab)

	, read_ahead(order_number(s1))

	, trace( [ `order number`, order_number ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================
		
	q0n(anything), `Total`, tab, `$`

	, read_ahead(total_net(d)), total_invoice(d)
	
	, newline

	, trace( [ `invoice total`, total_invoice ] )
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(buyer_contact_start_line)

		, or([  [ invoice_line_1, q10( invoice_line_1a ), invoice_line_2 ]

			, line

			])

		] )


] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `status`, tab, `vendor` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( invoice_line_1, [
%=======================================================================

	line_order_line_number(w1)

	, trace( [`line order line number`, line_order_line_number] )

	, or( [ line_item_for_buyer(s1), line_item_for_buyer(`Missing` ) ] ), tab

	, trace( [`line item_for_buyer`, line_item_for_buyer] )

	, line_descr(s1), tab

	, trace([`line descr`, line_descr])

	, ignored_line_quantity_uom_code(s1), tab

	, trace([`ignored_line_quantity_uom_code`, ignored_line_quantity_uom_code])

	, line_quantity(d), tab

	, trace( [`line quantity`, line_quantity] )

	, line_unit_amount(d), tab

	, trace( [`line unit_amount`, line_unit_amount] )

	, read_ahead(line_net_amount(d)), line_total_amount(d)

	, trace( [`line net amount`, line_net_amount] )

	, newline
] ).

%=======================================================================
i_line_rule_cut( invoice_line_1a, [
%=======================================================================

	read_ahead(dummy)

	, check(dummy(start) > -250), check(dummy(start) < 0)

	, append( line_descr(s1), ` `, `` ) 

	, newline

] ).


%=======================================================================
i_line_rule_cut( invoice_line_2, [
%=======================================================================

	retab( [ -230, 120 ] )

	, q10( [ line_item(w), trace( [`line item`, line_item] ) ] ), q0n(anything)

	, tab

	, q10( append( line_descr(s1), ` `, `` ) )

	, tab

	, q10( [ line_original_order_date(date), trace( [`line original order date`, line_original_order_date] ) ] )

	, newline
] ).

