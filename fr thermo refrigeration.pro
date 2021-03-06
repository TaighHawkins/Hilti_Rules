%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR THERMO REFRIGERATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_thermo_refrigeration, `22 January 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number_and_date
	
	, get_delivery_details

	, get_contacts

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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

	, buyer_registration_number( `FR-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
				, suppliers_code_for_buyer( `11623042` )		
	] )

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_and_date, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `CDE`, `:` ], order_number, s1, tab ] )
	  
	, order_date_line
	
	, q(0,25,line), order_number_remainder_line
	
] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	  `Le`, `:`, invoice_date(d), `-`
	  
	, the_month(w), `-`
	
	, check( i_user_check( convert_the_month, the_month, Num ) )
	
	, append( invoice_date( Num ), `/`, `/` )
	
	, append( invoice_date(d), ``, `` )
	
	, trace( [ `order number and date`, order_number, invoice_date ] )

] ).

%=======================================================================
i_line_rule( order_number_remainder_line, [ 
%=======================================================================

	  q0n(anything), `Affaire`, `:`
	  
	, append( order_number(s1), ` `, `` ), tab
	
	, trace( [ `order_number`, order_number ] )

] ).

%=======================================================================
i_user_check( convert_the_month, Month, Num )
%----------------------------------------
:-
%=======================================================================

	  string_to_lower( Month, Month_L )  
	, month_lookup( Month_L, Num )
.

month_lookup( `janvier`, `01` ).
month_lookup( `jan`, `01` ).
month_lookup( `février`, `02` ).
month_lookup( `fév`, `02` ).
month_lookup( `fev`, `02` ).
month_lookup( `mars`, `03` ).
month_lookup( `mar`, `03` ).
month_lookup( `avril`, `04` ).
month_lookup( `avr`, `04` ).
month_lookup( `mai`, `05` ).
month_lookup( `juin`, `06` ).
month_lookup( `jun`, `06` ).
month_lookup( `juillet`, `07` ).
month_lookup( `jul`, `07` ).
month_lookup( `août`, `08` ).
month_lookup( `aoû`, `08` ).
month_lookup( `aou`, `08` ).
month_lookup( `septembre`, `09` ).
month_lookup( `sep`, `09` ).
month_lookup( `octobre`, `10` ).
month_lookup( `oct`, `10` ).
month_lookup( `novembre`, `11` ).
month_lookup( `nov`, `11` ).
month_lookup( `décembre`, `12` ).
month_lookup( `déc`, `12` ).
month_lookup( `dec`, `12` ).
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_details_header_line, [ read_ahead( [ `ADRESSE`, `DE`, `LIVRAISON` ] ), delivery_hook(s1) ] ).
%=======================================================================	  
i_rule( get_delivery_details, [
%=======================================================================	  
	  
	  q(0,10,line), delivery_details_header_line
	  
	, delivery_thing_line( [ delivery_party ] )
	
	, delivery_thing_line( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).
  
%=======================================================================	  
i_line_rule( delivery_thing_line( [ Variable ] ), [
%=======================================================================	  
	  
	  nearest( delivery_hook(start), 10, 10 )
	  
	, Read_Variable
	
	, trace( [ String, Variable ] )
	
] )
:-
	Read_Variable =.. [ Variable, s1 ]
	
	, sys_string_atom( String, Variable )
.
    
%=======================================================================	  
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  
	  
	  nearest( delivery_hook(start), 10, 10 )
	  
	, delivery_postcode(f( [ begin, q(dec,5,5), end ] ) )
	
	, delivery_city(s1)
	
	, trace( [ `postcode and city`, delivery_postcode, delivery_city ] )
	
] ).
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Acheteur`, `:` ], buyer_contact_x, s1, newline ] )

	, check( i_user_check( sort_names, buyer_contact_x, Con ) )

	, buyer_contact( Con )
	
	, delivery_contact( Con )
	
	, trace( [ `buyer contact`, buyer_contact ] )
	
] ).

%=======================================================================
i_user_check( sort_names, Names, Con )
%-----------------------------------------------------------------------
:-
%=======================================================================
	sys_string_split( Names, ` `, [ H, H2 | [ ] ] ),
	strcat_list( [ H2, ` `, H ], Con )
.

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
	  
	, `MONTANT`, `GLOBAL`, `HORS`, `TAXES`,  tab
	
	, `en`, `EUR`, tab

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
			  
			, line_descr_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `LIGNE`, `ARTICLE`, tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `MONTANT`, `GLOBAL`, `HORS` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line

	, set( need_descr )
	
	, q10( line_descr_line )

	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ test( need_descr ), generic_item( [ line_descr, s1, newline ] ), clear( need_descr ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_no, d, tab ] )

	, or([ 
			line_item( f( [ q(alpha("HIL"),0,3), q(other("."),1,1), begin, q(dec,4,10), end ] ) )
			, line_item( f( [ q(alpha("HLT"),0,3), q(other("."),1,1), begin, q(dec,4,10), end ] ) )
	])
	
	, trace( [ `line item`, line_item ] )
	
	, qn0(word), tab

	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d ] )
	
	, or( [ newline
	
		, [ q10( tab ), generic_item( [ some_percent, d, [ `%`, newline ] ] ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).