%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH JOHNSON CONTROLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ch_johnson_controls, `27 November 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_address

	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_email
	
	, get_due_date

	, get_order_date
	
	, get_order_number

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

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10402444` ) ]    %TEST
	    , suppliers_code_for_buyer( `10491257` )                      %PROD
	]) ]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * DELIVERY LOCATION * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Bestellung` ], 200, order_number, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Ansprechpartner` ], 150, buyer_contact, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Mail` ], 200, buyer_email, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Liefertermin` ], 200, due_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamtwert`, `ohne`, `MWSt`, `.`], 300, total_net, d, none ] ) )
	  
	, generic_horizontal_details( [ [ `Gesamtwert`, `ohne`, `MWSt`, `.`], 300, total_invoice, d, none ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,10,line), order_date_line
	  
] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	  `Bestelldatum`, `:`, tab
	  
	, invoice_date(d), `.`
	
	, invoice_month_rule
	
	, append( invoice_date(d), ``, `` )
	
	, trace( [ `invoice date`, invoice_date ] )
	
] ).

%=======================================================================
i_rule( invoice_month_rule, [ 
%=======================================================================

	  or( [ [ `Januar`, month( `01` ) ]
	  
			, [ `Februar`, month( `02` ) ]
			
			, [ `März`, month( `03` ) ]
			
			, [ `April`, month( `04` ) ]
			
			, [ `Mai`, month( `05` ) ]
			
			, [ `Juni`, month( `06` ) ]
			
			, [ `Juli`, month( `07` ) ]
			
			, [ `August`, month( `08` ) ]
			
			, [ `September`, month( `09` ) ]
			
			, [ `Oktober`, month( `10` ) ]
			
			, [ `November`, month( `11` ) ]
			
			, [ `Dezember`, month( `12` ) ]
			
		] )
		
	, check( i_user_check( gen_same, month, MONTH ) )
	
	, trace( [ `month`, MONTH ] )
	
	, append( invoice_date( MONTH ), `/`, `/` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,10,line), buyer_ddi_line
	  
] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [ 
%=======================================================================

	  `Telefon`, `:`, tab
	  
	, buyer_ddi( `0` )
	
	, append( buyer_ddi(f( [ q(other("+"),1,1), q(dec("41"),2,2), begin, q([dec,other_skip("/")],8,11), end ] ) ), ``, `` )
	
	, trace( [ `buyer ddi`, buyer_ddi ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q0n(line), delivery_start_header
	
	, delivery_party_line
	
	, delivery_dept_line
	
	, q(0,2, delivery_address_line_line )
	
	, delivery_street_line
	
	, delivery_postcode_city_line
	
] ).

%=======================================================================
i_line_rule_cut( delivery_start_header, [
%=======================================================================

	 `Anlieferadresse`, newline
	 
	, trace( [`delivery start header found`] )

] ).

%=======================================================================
i_line_rule_cut( delivery_party_line, [
%=======================================================================

	  delivery_party(s1)
	  
	, check( delivery_party(end) < 0 )
	
	, trace( [ `delivery party`, delivery_party ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_dept_line, [
%=======================================================================

	  delivery_dept(s1)
	  
	, check( delivery_dept(end) < 0 )
	
	, trace( [ `delivery dept`, delivery_dept ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_address_line_line, [
%=======================================================================

	  delivery_address_line(s1)
	  
	, check( delivery_address_line(end) < 0 )
	
	, trace( [ `delivery address line`, delivery_address_line ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_street_line, [
%=======================================================================

	  delivery_street(s1)
	  
	, check( delivery_street(end) < 0 )
	
	, trace( [ `delivery street`, delivery_street ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_postcode_city_line, [
%=======================================================================

	  q0n(word), q10( `-` )
	  
	, delivery_postcode(d)
	  
	, delivery_city(s1)
	
	, check( delivery_city(end) < 0 )
	
	, trace( [ `delivery stuffs`, delivery_postcode, delivery_city ] )

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

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_underscore_line
		
				, line_invoice_rule
		
				, line_invoice_wrong_item_location_rule
		
				, line_continuation_line
			
				, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_underscore_line, [ qn0( `_` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_header_line, [ `Kurztext`, tab, `Lief`, `.`, `-`, `Produktnr`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  or( [ [ `Gesamtwert`, `ohne`, `MWSt`, `.`, `:` ]
	  
			, [ `Bitte`, `Bestell`, `-`, `Nr` ]
			
		] )
	  
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line_one
	  
	, line_invoice_line_two

] ).

%=======================================================================
i_rule_cut( line_invoice_wrong_item_location_rule, [
%=======================================================================

	  set( wrong_item )
	  
	, line_invoice_line_one
	  
	, line_invoice_line_two
	
	, clear( wrong_item )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_one, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, q10( [ test( wrong_item ), generic_item( [ line_item, s1, tab ] ) ] )
	
	, generic_item( [ line_quantity, d, none ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item( [ line_unit_amount, d, q10( tab ) ] )
	
	, generic_item( [ trash, s1, newline ] )
	
	, with( invoice, due_date, DATE )
	
	, line_original_order_date( DATE )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_two, [
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )
	  
	, or( [ test( wrong_item )
	
			, generic_item( [ line_item, s1, tab ] )
	
			, line_item( `Missing` )
			
		] )
	
	, generic_item( [ line_net_amount, d, q10( tab ) ] )
	
	, generic_item( [ trash, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  append( line_descr(s1), ` `, `` ), newline

] ).