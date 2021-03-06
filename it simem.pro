%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT SIMEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_simem, `01 July 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_delivery_address
	
	, get_contacts

	, get_invoice_lines

	, get_totals
	

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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13134058` )                      %PROD
	]) ]  	
	
	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
	    , delivery_note_number( `13134058` )                      %PROD
	]) ]  
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,5,line), generic_horizontal_details( [ [ `Ordine`, `Acquisto` ], order_number, s1, gen_eof ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ q(0,10,line), order_date_line ] ).
%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	  q0n(anything), `Data`, `Ordine`
	  
	, invoice_date(d), `.`
	  
	, the_month(w)
	
	, check( i_user_check( convert_the_month, the_month, Num ) )
	
	, append( invoice_date( Num ), `/`, `/` )
	
	, append( invoice_date(d), ``, `` )
	
	, trace( [ `order number and date`, order_number, invoice_date ] )

] ).

%=======================================================================
i_user_check( convert_the_month, Month, Num )
%----------------------------------------
:-
%=======================================================================

	  string_to_lower( Month, Month_L )  
	, month_lookup( Month_L, Num )
.

month_lookup( `gennaio`, `01` ).
month_lookup( `genn`, `01` ).
month_lookup( `febbraio`, `02` ).
month_lookup( `febb`, `02` ).
month_lookup( `marzo`, `03` ).
month_lookup( `mar`, `03` ).
month_lookup( `aprile`, `04` ).
month_lookup( `apr`, `04` ).
month_lookup( `maggio`, `05` ).
month_lookup( `magg`, `05` ).
month_lookup( `giugno`, `06` ).
month_lookup( `luglio`, `07` ).
month_lookup( `agosto`, `08` ).
month_lookup( `ag`, `08` ).
month_lookup( `settembre`, `09` ).
month_lookup( `sett`, `09` ).
month_lookup( `ottobre`, `10` ).
month_lookup( `ott`, `10` ).
month_lookup( `novembre`, `11` ).
month_lookup( `nov`, `11` ).
month_lookup( `dicembre`, `12` ).
month_lookup( `dic`, `12` ).
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================	  
	  
	  q(0,20,line), delivery_header_line( [ Left ] )
	  
	, trace( [ `found header` ] )

	, delivery_thing( 1, Left, 0, [ delivery_street ] )
	
	, delivery_postcode_city_line( 1, Left, 0 )

	, delivery_thing( 1, Left, 0, [ delivery_location ] )
] ).

%=======================================================================
i_line_rule( delivery_header_line( [ Left ] ), [ 
%=======================================================================

	  `Spedire`, read_ahead( `a` ), left_margin(w), `.`, `.`, `.`
	  
	, generic_item( [ delivery_party, s1, gen_eof ] ) 
	
	, check( left_margin(end) = Left )
	
] ).

%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ generic_item( [ Variable, s1, newline ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  delivery_postcode( f( [ begin, q(dec,4,5), end ] ) )
	  
	, delivery_city(s1), gen_eof
	
	, trace( [ `delivery stuffs`, delivery_postcode, delivery_city ] )

] ).

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Addetto`, `Acquisti` ], buyer_contact, s1, gen_eof ] )
	  
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `CdC` ], 100, buyer_ddi, s1, gen_eof ] )
	  
	, check( buyer_ddi = DDI )
	
	, delivery_ddi( DDI )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  q0n(anything)
	  
	, `Totale`, `EURO`, tab
	  
	, read_ahead( [ total_net(d) ] )

	, total_invoice(d), newline
	
	, trace( [ `total_invoice`, total_invoice ] )

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

		  or( [ 
		
			  line_invoice_rule
			  
			, line_customer_comments_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, `Nr`, `.`, tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  or( [ [ `Totale`, `EURO` ]
	  
		, [ `.`, `.`, `.`, `.`, `co`, `.`, `n`, `.`, `tin`, `.`, `ua` ]

		, [ `.`, `.`, `.`, `.`, `continua` ]

	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line
	  
	, line_item_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, `q10`, tab ] )
	
	, generic_item( [ some_item, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, `q10`, tab ] )

	, generic_item( [ line_quantity, d, `q10`, tab ] )
	
	, or( [ [ generic_item( [ line_quantity_uom_code, s1, tab ] )
	
			, generic_item( [ line_unit_amount, d, tab ] )
	
			, generic_item( [ line_net_amount, d, newline ] )
			
		]
		
		, generic_item( [ line_quantity_uom_code, s1, newline ] )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `HILTI`, or( [ [ `-`, q10( [ `Cod`, `.` ] ) ], [ `Cod`, `.` ] ] )
	  
	, line_item(s1)
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( line_customer_comments_line, [
%=======================================================================

	  `Per`, `Commessa`, q10( tab )
	  
	, or( [ [ without( customer_comments )
	
			, generic_item( [ customer_comments, s1, newline ] )
	
			, check( customer_comments = Cust )
	
			, shipping_instructions( Cust )
			
		]
		
		, [ with( customer_comments )
		
			, read_ahead( append( customer_comments(s1), `~`, `` ) )
			
			, append( shipping_instructions(s1), `~`, `` )
			
		]
		
	] )

] ).