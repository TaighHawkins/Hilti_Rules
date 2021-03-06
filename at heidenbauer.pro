%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AT HEIDENBAUER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_heidenbauer, `10 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( same_line, 6 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_suppliers_code_for_buyer

	, get_order_number
	
	, get_order_date

	, get_delivery_details

	, get_contacts
	
	, get_emails
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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
	, set( no_total_validation )
	
	, total_net( `0 `)
	, total_invoice( `0` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ suppliers_code_for_buyer( `11205959` ) ] ):- grammar_set( test_flag ).
%=======================================================================	
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================	  
	  
	  q0n(line)
	  
	, or( [ [ generic_horizontal_details( [ [ `Heidenbauer`, `Industriebau`, `GmbH` ] ] )	
			, suppliers_code_for_buyer( `16693225` )		
		]
		
		, [ generic_horizontal_details( [ [ `Metallbau`, `Heidenbauer`, `GmbH` ] ] )
			, suppliers_code_for_buyer( `10040856` )
		]
		
	] )
	
] ):- not( grammar_set( test_flag ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `B`, `e`, `s`, `t`, `e`, `l`, `l`, `u`, `n`, `g` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Datum`, `:` ], 300, invoice_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ [ `Sachbearbeiter`, `:`, tab, `Ing`, `.` ], buyer_contact_x, s1 ] )
	
	, check( i_user_check( reverse_names, buyer_contact_x, Con ) )
	, buyer_contact( Con )

] ).

%=======================================================================
i_user_check( reverse_names, In, Out ):- 
%=======================================================================

	sys_string_split( In, ` `, [ Surname | Names ] ),
	sys_append( Names, [ Surname ], OutList ),
	sys_stringlist_concat( OutList, ` `, Out )
.

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:` ], 250, buyer_email, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ `Lieferadresse`, `:`, tab, generic_item( [ delivery_party, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), delivery_header_line

	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).


%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ read_ahead( `Auftragsnr` ), retab( [ 500 ] ) ], customer_comments, s1 ] )
	  
	, check( customer_comments = Com )
	, shipping_instructions( Com )

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

	, q0n(

		or( [ 
		
			  line_invoice_rule
			  
			, line_defect_line

			, line

		] )

	), line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, q10( tab ), `Artikel`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ `Zahlungskondition`
	
		, `Nettosumme`
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).


%=======================================================================
i_line_rule_cut( line_defect_line, [ q0n(anything), some(date), tab, force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q( 2,0, [ peek_fails( or( [ line_end_line, generic_line( [ [ q0n(anything), some(date) ] ] ) ] ) ), line_descr_line ] )
	
	, clear( got_descr )
	
	, or( [ peek_fails( test( item_missing ) )
	
		, [ test( item_missing )
			, line_item( `Missing` )
			, clear( item_missing )
		]
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )

	, or( [ [ q10( [ line_descr(sf), set( got_descr ) ] )
			, set( regexp_cross_word_boundaries )
			, generic_item( [ line_item, [ q(alpha("HI"),2,2), begin, q(dec,4,10), end ] ] )
			, clear( regexp_cross_word_boundaries )
		]
		
		, [ set( item_missing ) ]
	] )
	
	, q10(
		or( [ [ test( got_descr ), append( line_descr(s1), ` `, `` ) ]
		
			, [ peek_fails( test( got_descr ) ), generic_item( [ line_descr, s1 ] ) ]
			
		] )
	)
	
	, tab
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w ] )

	, or( [ [ tab, generic_item( [ line_unit_amount, d, [ q10( [ `/`, num(d) ] ), tab ] ] )
	
			, generic_item( [ line_net_amount, d, [ `EUR`, newline ] ] )
	
		]
		
		, [ tab, `EUR`, newline ]
		
		, newline
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	read_ahead( dummy )
	, check( dummy(start) < -200 )
	
	, q10( or( [ peek_fails( test( item_missing ) )

			, [ test( item_missing )
				, read_ahead( [ q0n(word), generic_item( [ line_item, [ q(alpha("HI"),0,2), begin, q(dec,4,10) ] ] ) ] )
				, clear( item_missing )
			]
		] )
	)	

	, or( [ [ peek_fails( test( got_descr ) )
	  
			, generic_item( [ line_descr, s1 ] )
			
			, set( got_descr )

		]
		
		, [ test( got_descr )
		
			, append( line_descr(s1), ` `, `` )
			
		]
		
	] )

] ).