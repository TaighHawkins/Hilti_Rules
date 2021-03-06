%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FR ALSTOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fr_alstom, `11 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_totals
	
	, check_for_avenant

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AVENANT RULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_avenant, [ 
%=======================================================================

	q0n(line), generic_line( [ `Avenant` ] )
	
	, trace( [ `Avenant rule triggered - document NOT processed` ] )
	, delivery_note_reference( `special_rule` )
	, set( do_not_process )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_contacts

	, get_invoice_lines
	

] ):- not( grammar_set( do_not_process ) ).

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
				, suppliers_code_for_buyer( `11625108` )		
	] )

	, type_of_supply( `01` )
	
	, delivery_note_number( `18413657` )

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Alstom Grid` )

	, set( leave_spaces_in_order_number )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ [ `N`, `/`, `réf`, `.`, `:` ], order_number, s1 ] )

	, check( order_number = Ord )
	, shipping_instructions( Ord )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ [ `Commande`, `Du` ], invoice_date, date ] )

] ).
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================	  
	  
	  q(0,15,line), generic_horizontal_details( [ [ `Acheteur`, `:` ], buyer_contact_x, s1 ] )
	  
	, check( i_user_check( reverse_names, buyer_contact_x, Con ) )

	, buyer_contact( Con )
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_user_check( reverse_names, NamesIn, NamesOut )
%=======================================================================
:-
	sys_string_split( NamesIn, ` `, NamesSplit ),
	sys_reverse( NamesSplit, NamesReverse ),
	wordcat( NamesReverse, NamesOut )
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

	  `Valeur`, `Commande`, `:`,  tab
		
	, read_ahead( [ total_net(d) ] )

	, total_invoice(d)
	
	, trace( [ `total_invoice`, total_invoice ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  peek_ahead( line_header_line )
	 
	, generic_line( [ [ `Poste`, generic_item( [ line_order_line_number, d, newline ] ) ] ] )
	
	, q01( line )
	
	, line_other_header_line
	
	, line

	, line_order_line
	
	, line
	
	, generic_line( [ [ `Designation`, `:`, generic_item( [ line_descr, s1 ] ) ] ] )
	
	, line_item_line
	
	, q(0,15,line)

	, line_end_line
	
	, q10( [ test( additional_item )
		, check( line_quantity = Qty )
		, check( line_descr = Descr )
		, check( additional_item = Item )
		, check( line_order_line_number = LineNo )
		, check( line_item_for_buyer = BuyerItem )
		, check( line_quantity_uom_code = UoM )
		, check( line_original_order_date = Date )
		
		, line_order_line_number( LineNo )
		, line_item_for_buyer( BuyerItem )
		, line_quantity( Qty )
		, line_quantity_uom_code( UoM )
		, line_original_order_date( Date )
		, line_descr( Descr )
		, line_item( Item )
		, trace( [ `Additional line created` ] )
		
		, remove( additional_item )
		, clear( additional_item )
	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Poste`, num(d), newline ] ).
%=======================================================================
i_line_rule_cut( line_other_header_line, [ `N`, `°`, `ARTICLE` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `PRIX`, `TOTAL`, `POSTE`, q10( tab ), `:`, tab, generic_item( [ line_net_amount, d ] ) ] ).
%=======================================================================
i_line_rule_cut( line_order_line, [
%=======================================================================

	  generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_original_order_date, date, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `Reference`, `Fournisseur`, `:`
	  
	, or( [ [ q0n(anything)
	
			, set( regexp_cross_word_boundaries )
			, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
			
			, q10( [ q0n( [ peek_fails( or( [ `OFFRE`, `DEVIS` ] ) ), word ] )
				, additional_item( f( [ begin, q(dec,4,10), end ] ) )
				,set( additional_item )
			] )				
			
			, clear( regexp_cross_word_boundaries )

		]
		
		, [ line_item( `Missing` ) ]
		
	] )
	
] ).