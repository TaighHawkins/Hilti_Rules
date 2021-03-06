%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SE EAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( se_eab, `20 February 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details

	, get_buyer_contact

	, get_customer_comments

	, get_order_date

	, get_order_number
	
	, get_invoice_lines

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, [ qn0(line), invoice_total_line]

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

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `SE-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2600`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `11327254` )
	
	, set( reverse_punctuation_in_numbers )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line), generic_vertical_details( [ [ at_start, `Vår`, `referens` ], buyer_contact, s1 ] )
	 
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ at_start, `Leveransadress` ] ] )
	  
	, delivery_line( [ delivery_party ] )
	
	, delivery_line( [ delivery_street ] )
	, delivery_postcode_and_city_line

] ).

%=======================================================================
i_line_rule( delivery_line( [ Var ] ), [
%=======================================================================

	generic_item( [ Var, s1 ] )

] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  q10( [ `SE`, `-` ] )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,3,3), end ] ] )
	, append( delivery_postcode( f( [ begin, q(dec,2,2), end ] ) ), ` `, `` )
	
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

	  q(0,10,line), generic_vertical_details( [ [ `Ordernr` ], order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,10,line), generic_vertical_details( [ [ `Orderdatum` ], invoice_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	  q(0,30,line), generic_vertical_details( [ `Godsmärke`, customer_comments, s1 ] )
	  
	, check( customer_comments = Com )
	, shipping_instructions( Com )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	  `Totalt`, tab, `SEK`, tab

	, set( regexp_cross_word_boundaries )
	, read_ahead(total_invoice(d))

	, total_net(d)
	, clear( regexp_cross_word_boundaries )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
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
i_line_rule_cut( line_header_line, [ `Rad`, `nr`, q10( tab ), `Ert`, header] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Totalt` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, generic_line( [ [ q0n( [ some(s1), tab ] ), `Levdat`, tab, date_num(d) ] ] )
	
	, check( i_user_check( convert_date_into_usable_format, date_num, Date ) )
	, line_original_order_date( Date )
	
	, q10( [ without( delivery_date )
		, delivery_date( Date )
	] )

	, line_item_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, set( regexp_cross_word_boundaries )
	, generic_item_cut( [ line_quantity, d ] )
	, clear( regexp_cross_word_boundaries )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] ).
%=======================================================================

%=======================================================================
i_user_check( convert_date_into_usable_format, DateIn, DateOut )
%=======================================================================
:-
	sys_string_length( DateIn, Len ),
	( Len = 5
		->	WeekLen = 2
		;	WeekLen = 1
	),
	
	q_sys_sub_string( DateIn, 1, 2, YearEnd ),
	strcat_list( [ `20`, YearEnd ], YearRaw ),
	sys_string_number( YearRaw, Year ),
	q_sys_sub_string( DateIn, 3, WeekLen, WeekRaw ),
	sys_string_number( WeekRaw, WeekNum ), 
	q_sys_sub_string( DateIn, Len, 1, DayRaw ),
	sys_string_number( DayRaw, DayPlusOne ),
	sys_calculate( Day, DayPlusOne - 1 ),
	trace( [ `Date`, Year, WeekNum, Day ] ),
	
	q_sys_member( Mon, [ mon( 1, 1 ), mon( 2, 2 ), mon( 3, 2 ), mon( 4, 2 ), mon( 5, 2 ), mon( 6, 2 ), mone( 7, 2 ) ] ),
	Mon = mon( Mon_d, Mon_w ),
	
	Monday_date = date( Year, 1, Mon_d ),
	week_day( Monday_date, `Monday` ),
	
	sys_calculate( Week, WeekNum - Mon_w ),
	
	date_add( Monday_date, weeks( Week ), Date1 ),
	date_add( Date1, days( Day ), DateRaw ),
	date_string( DateRaw, `d/m/y`, DateOut ),
	trace( [ `Date converted to`, DateOut ] )
.

	
