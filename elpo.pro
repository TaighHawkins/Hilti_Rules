%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ELPO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( elpo, `09 March 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
			[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
			, supplier_registration_number( `P11_100` )                      %PROD
		]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
			[ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
			, suppliers_code_for_buyer( `12955189` )                      %PROD
		]) ]

	, [ q0n(line), get_delivery_address ]

	, [ q0n(line), get_buyer_contact ]
	
	, [ q0n(line), get_buyer_email ]

	, [ q0n(line), get_buyer_ddi ]

	, [ q0n(line), order_number_date_line ]
	
	, get_line_original_order_date
	
%	, shipping_rule
	, get_cig_cup
	
	, invoice_total_rule

	, get_invoice_lines_without_nets

	, get_invoice_lines

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  delivery_header_line

	, delivery_party_line
	
	, delivery_street_line

	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	  q0n(anything)

	, `Destinazione`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s1), or( [ tab, newline ] )
	
	, check( delivery_party(end) < 0 )

	, trace([ `delivery party`, delivery_party ])

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s1), or( [ tab, newline ] )
	
	, check( delivery_street(end) < 0 )

	, trace([ `delivery party`, delivery_party ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	delivery_postcode(d)
	
	, check( delivery_postcode(end) < 0 )

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1), or( [ tab, newline ] )

	, trace([ `delivery city`, delivery_city ])

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CIG CUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_cig_cup, [ 
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ `Cup`, `:` ], cup, s1 ] )
	
	, generic_horizontal_details( [ [ `Cig`, `:` ], cig, s1 ] )
	
	, check( cup = Cup )
	, check( cig = Cig )
	
	, check( strcat_list( [ `CIG:`, Cig, ` CUP:`, Cup ], AL ) )
	, delivery_address_line( AL )
	, trace( [ `Delivery Address Line`, delivery_address_line ] )

] ).

%=======================================================================
i_line_rule( cig_cup_line, [ 
%=======================================================================

	q(2,2,
		[ q0n(anything)
			, or( [ [ peek_fails( test( got_cig ) ), `CIG`, cig(w), set( got_cig ) ]
			
				, [ peek_fails( test( got_cup ) ), `CUP`, cup(w), set( got_cup ) ]
			] )
		]
	)	

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( shipping_rule, [ 
%=======================================================================

	  q0n(line), shipping_line
	  
	, shipping_two_line
	
] ).

%=======================================================================
i_line_rule( shipping_line, [ 
%=======================================================================

	  read_ahead( [ `CUP`, `:` ] )
	  
	, read_ahead( [ customer_comments(s1), newline ] )
	
	, shipping_instructions(s1), newline

]).

%=======================================================================
i_line_rule( shipping_two_line, [ 
%=======================================================================

	  read_ahead( [ `CIG`, `:` ] )
	  
	, read_ahead( [ append( customer_comments(s1), ` `, ``)  , newline ] )
	
	, append( shipping_instructions(s1), ` `, `` ), newline

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_line_original_order_date, [
%=======================================================================

	  q0n(line), line_original_order_date_header
	  
	, line_original_order_date_line

] ).

%=======================================================================
i_line_rule( line_original_order_date_header, [ 
%=======================================================================

	  `Termine`,  `di`, `consegna`

	, trace([ `priginal_order_date_found, header found` ])

]).

%=======================================================================
i_line_rule( line_original_order_date_line, [ 
%=======================================================================

	  due_date(date), tab
	  
	, trace( [ `due date`, due_date ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Elaboratore`, tab

	, read_ahead(buyer_contact(s1))

	, delivery_contact(s1), or( [ tab, newline ] )

	, trace( [ `buyer contact`, buyer_contact ] ) 

	, trace( [ `delivery contact`, delivery_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	 or( [ [ `T`, `el` ], [ `Tel` ] ] ), `.`, `:`, tab

	, read_ahead( buyer_ddi(s1) )
	
	, delivery_ddi(s1), or( [ tab, newline ] )
	
	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	`e`, `-`, `mail`, `:`, tab
	
	, set(regexp_cross_word_boundaries)

	, read_ahead(buyer_email(s1))

	, delivery_email(s1)
	
	, clear(regexp_cross_word_boundaries)
	
	, or( [ tab, newline ] )

	, trace( [ `buyer email`, buyer_email ] ) 

	, trace( [ `delivery email`, delivery_email ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( order_number_date_line, [ 
%=======================================================================

	  `Nr`, `.`, q01( tab), order_number(s1), tab
	  
	, trace( [ `order number`, order_number ] )
	
	, `Data`, tab, invoice_date(date), tab
	
	, trace( [ `invoice date`, invoice_date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( invoice_total_rule, [
%=======================================================================

	  q0n(line), line_end_line
	
	, net_line
	
	
] ).

%=======================================================================
i_line_rule( net_line, [
%=======================================================================

	  read_ahead( total_net(d) ), total_invoice(d), tab
	
	, trace( [ `total net`, total_net ] )
	
	, trace( [ `total invoice`, total_invoice ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HILTI ITEM NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( hilti_item_number, [
%=======================================================================

	  read_ahead( line_item_for_buyer(f( [ begin, q(alpha("HIL"),0,3), q(dec,4,10), end ] ) ) )
	  
	, line_item(f( [ q(alpha("HIL"),0,3), begin, q(dec,4,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_rule( other_hilti_item_number, [
%=======================================================================

	  read_ahead( line_item_for_buyer(f( [ q(alpha("ART"),3,3), q(other("."),1,1), begin, q(dec,4,10), end ] ) ) )
	  
	, line_item(f( [ q(alpha("ART"),3,3), q(other("."),1,1), begin, q(dec,4,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_with_item_number_rule, line_invoice_rule
		
		, line

			])

		] )
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, q01(tab), `Descrizione`, tab, `UM`, tab, word, tab, `Prezzo` ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, newline ] ), set( continuation ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Valore`, `Merci`, tab

] ).

%=======================================================================
i_rule( line_invoice_with_item_number_rule, [
%=======================================================================

	  line_invoice_with_item_number_one_line
	  
	, line_invoice_with_item_number_two_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_with_item_number_one_line, [
%=======================================================================

	  line_no(d), tab
	  
	, hilti_item_number, tab
	
	, line_quantity_uom_code(w), tab
	
	, trace( [ `quantity uom`, line_quantity_uom_code ] )
	
	, line_quantity(d), tab
	
	, trace( [ `quantity`, line_quantity ] )
	
	, dummy_cost(d), tab
	
	, q10( [ dummy_disc(d), tab ] )
	
	, line_net_amount(d), newline
	
	, trace( [ `line net`, line_net_amount ] )
	
	, with( invoice, due_date, DATE )
	
	, line_original_order_date( DATE )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_with_item_number_two_line, [
%=======================================================================

	  line_descr(s1), newline
	  
	, check( line_descr(start) > -400 )
	  
	, trace( [ `line description`, line_descr ] )
	
] ).

%=======================================================================
i_rule( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q01( line_descr_line )

	, line_invoice_two_line
	
	, clear( continuation )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  line_no(d), tab, dummy_descr(s1), tab
	  
	, trace( [ `description`, dummy_descr ] )
	
	, line_quantity_uom_code(w), tab
	
	, trace( [ `quantity uom`, line_quantity_uom_code ] )
	
	, line_quantity(d), tab
	
	, trace( [ `quantity`, line_quantity ] )
	
	, dummy_cost(d), tab
	
	, q10( [ dummy_disc(d), tab ] )
	
	, line_net_amount(d), newline
	
	, trace( [ `line net`, line_net_amount ] )
	
	, with( invoice, due_date, DATE )
	
	, line_original_order_date( DATE )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_two_line, [
%=======================================================================

	  or( [ [ q0n(word), hilti_item_number ], [ read_ahead( [ q0n(word), other_hilti_item_number ] ) ] ] )
	  
	, or( [ [ test( continuation ), append( line_descr(sf), ` `, `` ) ]
	
		, line_descr(sf)
		
	] ), q10( [ `ART`, `.`, word ] ), newline
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES WITHOUT NETS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines_without_nets, [
%=======================================================================

	 line_header_without_nets_line

	, qn0( [ peek_fails(line_end_without_nets_line)

		, or([ line_invoice_without_nets_rule
		
		, line

			])

		] )
] ).

%=======================================================================
i_line_rule_cut( line_header_without_nets_line, [ 
%=======================================================================

	  `Pos`, `.`, q10( tab ), `Descrizione`, tab, `UM`, tab, word,  newline
	  
	, trace( [ `found header` ] )
	  
] ).
%=======================================================================
i_line_rule_cut( line_end_without_nets_line, [
%=======================================================================

	`Pagina`, tab

] ).

%=======================================================================
i_rule( line_invoice_without_nets_rule, [
%=======================================================================

	  line_invoice_without_nets_line
	  
	, line_invoice_without_nets_two_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_without_nets_line, [
%=======================================================================

	  line_no(d), tab
	  
	, hilti_item_number, tab
	  
	, trace( [ `line_item`, line_item ] )
	
	, line_quantity_uom_code(w), tab
	
	, check( line_quantity_uom_code(start) > 200 )
	
	, trace( [ `quantity uom`, line_quantity_uom_code ] )
	
	, read_ahead( [ line_quantity(d), newline ] )
	
	, line_net_amount(d), newline 
	
	, trace( [ `line_net`, line_net_amount ] )
	
	, or( [ [ with( total_invoice )
	
				, check( sys_calculate_str_add( line_net_amount, total_invoice, RUNNING ) )
				
				, total_invoice( RUNNING )
				
				, total_net( RUNNING )
				
			]
			
			, [ without( total_invoice )
			
				, check( i_user_check( gen_same, line_net_amount, FIRST )  )
				
				, total_invoice( FIRST )
				
			]
				
	] )
	
	, trace( [ `total`, total_invoice, total_net ] )
	
	, with( invoice, due_date, DATE )
	
	, line_original_order_date( DATE )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_without_nets_line, [
%=======================================================================

	  line_descr(s1), newline
	  
	, check( line_descr(start) > -400 )
	  
	, trace( [ `description`, line_descr ] )
	

] ).