%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TRANSLEC COMMON INC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( translec_common_inc, `25 November 2014` ).

i_date_format( `d/m/y` ):- grammar_set( alt_date ).
i_date_format( `y-m-d` ):- not( grammar_set( alt_date ) ).

i_format_postcode( X, X ).


i_correlate_amounts_total_to_use( total_net, net_subtotal_1 ).

i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, check_punctuation

	, get_sold_to_code

	,[q0n(line), force_repq_defect_line ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_details ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	, get_invoice_lines

	,[q0n(line), get_invoice_totals]

	, get_buyer_email

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`01`)

	, cost_centre(`Standard`)

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11235054` ) ]    %TEST
	    , suppliers_code_for_buyer( `10682728` )                      %PROD
	]) ]

] ).

%=======================================================================
i_rule( check_punctuation, [ q0n(line), check_punctuation_line ] ).
%=======================================================================
i_line_rule( check_punctuation_line, [ 
%=======================================================================

	`Total`, `:`, tab, `$`, dummy(f( [ begin, q([dec,other(",")],1,10), q(other("."),1,1), q(dec,2,2), end ] ) )
	
	, newline
	
	, clear( reverse_punctuation_in_numbers )
	
	, trace( [ `Normal numbers` ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_sold_to_code, [ 
%=======================================================================

	q0n(line), facturation_line

	, trace([ `Facturation`, suppliers_code_for_buyer ])

]).


%=======================================================================
i_line_rule( facturation_line, [ 
%=======================================================================

	or([ `Facturation`, `billing` ]), q10(`:`), q01(tab)

	, or([ 
		[ `2075`, suppliers_code_for_buyer( `10682728` ) ]

		, [ `2300`, suppliers_code_for_buyer( `17625939` ) ]
		
		, [ `178`, suppliers_code_for_buyer( `18471426` ), set( alternate_name) ]

	])


]).



%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	 trace([`looking for email`]), buyer_email(FROM)
	, trace([ `buyer email`, buyer_email ])

] )

:-
	i_mail( from, FROM )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FORCE REPQ DEFECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( force_repq_defect_line, [
%=======================================================================

	q0n(anything)

	, or([ `Réquisition`, [`req`, `#`] ]),  `:`, q01(tab)

	, `repq`

	, force_result( `defect` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	delivery_party_line

	, or([ livraison_line, gen_line_nothing_here([-40,20,20] ) ]) 

	, delivery_street_line_one

	, q10( [ clear(street_found)

			, check(i_user_check( translec_street, delivery_street_one, CITY, STATE_CODE, POST_CODE) )

			, delivery_city(CITY), delivery_state(STATE_CODE), delivery_postcode(POST_CODE)

			, set(street_found)

		] )


	, q10([ q10( gen_line_nothing_here([-40,20,20]) )

			, delivery_street_line_two 

			, q10( [ peek_fails(test(street_found))

				, trace([`looking`, delivery_street_two ])

				, check(i_user_check( translec_street, delivery_street_two, CITY, STATE_CODE, POST_CODE) )

				, trace([`found`, CITY ])

				, delivery_city(CITY), delivery_state(STATE_CODE), delivery_postcode(POST_CODE)

				, set(street_found)

				] )

		])

	, check( i_user_check( gen_same, delivery_street_one, FIRST_STREET) )

	, delivery_street(FIRST_STREET)

	, or([ test(street_found)

			, [ q(0, 3, line), delivery_city_postcode_line

			, q10( [ check(i_user_check( ca_state, CODE, delivery_state)), delivery_state(CODE) ]) ]


		])

	
] ).



%=======================================================================
i_line_rule_cut( livraison_line, [ or([`Livraison`, `delivery` ]), `:` ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( delivery_party_line, [ 
%=======================================================================

	or([ `Fournisseur`, `supplier` ]), `:`

%	, q10([ q0n(anything), tab, delivery_party(s1), newline ])

	, delivery_party(`TRANSELEC COMMON INC`)

	, trace([ `delivery party`, delivery_party ])
	
] ).

%=======================================================================
i_line_rule_cut( delivery_street_line_one, [ 
%=======================================================================

	nearest( -40, 20, 20)

	, delivery_street_one(s1)

	, trace([ `delivery street one`, delivery_street_one ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( delivery_street_line_two, [ 
%=======================================================================

	nearest( -40, 20, 20)

	, read_ahead(delivery_street_two(s1)), delivery_street(s1)

	, trace([ `delivery street two`, delivery_street ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( delivery_city_postcode_line, [ 
%=======================================================================

	nearest( -40, 20, 20)

	, q10([ delivery_street(s), `,` ])

	, delivery_city(s), `,`, trace([ `delivery city`, delivery_city ])

	, or([ 
		[ delivery_state(s), trace([ `delivery state`, delivery_state ])
		, q10(tab), delivery_postcode(s), trace([ `delivery postcode`, delivery_postcode ]) ]

		, [  delivery_state(f([begin, q(alpha,2,2), end])), trace([ `delivery state`, delivery_state ]) ]

	])

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [ 
%=======================================================================

	get_buyer_contact_header

	, q01(line)

	, get_buyer_contact_line

	, q01(line)

	, q10(get_buyer_ddi_line)

	, q01(line)

	, q10(get_buyer_fax_line)

] ).

%=======================================================================
i_line_rule( get_buyer_contact_header, [ 
%=======================================================================

	or( [`Acheteur`, `buyer` ])

	, trace([ `buyer contact header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	buyer_contact(s1), check(buyer_contact(start) < -300)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi_line, [ 
%=======================================================================

	or([ [`Tél`, `.`], `tel` ]), `:`, q01(tab)

	, buyer_ddi(s1)

	, newline

	, trace([ `buyer ddi`, buyer_ddi ])

] ).

%=======================================================================
i_line_rule( get_buyer_fax_line, [ 
%=======================================================================

	`fax`, `:`, q10(tab)

	, buyer_fax(s1)

	, newline

	, trace([ `buyer fax`, buyer_fax ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY FROM CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(anything), `Contact`, q10(tab), `:`, q10(tab(100))

	, delivery_contact(s1)

	, trace([ `delivery contact`, delivery_contact ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, or([ `Commande`, [`po`, `#`] ]), `:`, q01(tab)

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	or([ [`Date`, `de`, `la`, `commande`], [`order`, `date`] ]), `:`, q01(tab)

	, q10( [ peek_ahead( [ num(d), `/` ] ), set( alt_date ), trace( [ `Alternate date` ] ) ] )
	
	, invoice_date(date)

	, trace( [ `order date`, invoice_date ] ) 

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	or([ [`Sous`, `-`, `total`], [`sub`, `total` ] ]), `:`, tab

	, set( regexp_cross_word_boundaries )

	, generic_item( [ total_invoice, d, or( [ `$`, test( at_front ) ] ) ] )

	, clear( regexp_cross_word_boundaries )

	, with( invoice, net_subtotal_2, NET_2 )
	
	, check( sys_calculate_str_subtract(total_invoice, NET_2, NET ) )
	
	, net_subtotal_1( NET )
	
	, gross_subtotal_1( NET )
	
	, trace( [ `net 1`, net_subtotal_1 ] )
	
	, trace( [ `gross 1`, gross_subtotal_1 ] )

	, trace( [ `total invoice`, total_invoice ] )

	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line
	
	, qn0( line_trash_line )

	, qn0( [ peek_fails(line_end_line)

		, or([  ignore_reference_soumission_line
		
			, ignore_majoration_prix_line
		
			, line_invoice_line
		
			, line_continuation_line
			
			, line

		])

	] )
	
	, q10( [ without( net_subtotal_2 ), net_subtotal_2( `0` )
	
		, gross_subtotal_2( `0` )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( ignore_reference_soumission_line, [ or( [ `Référence`, [ or( [ `Réf`, `RÉF` ] ), `.` ] ] ), `soumission` ] ).
%=======================================================================
i_line_rule_cut( line_header_line, [ or([ [`Code`, `TCI`], [ `TCI`, `product`, `#` ] ])  ] ).
%=======================================================================
i_line_rule_cut( line_trash_line, [ generic_item( [ trash, s1, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [`Sous`, `-`, `total`, `:`, tab]
	
		, [`Acheteur`, gen_eof]
		
		, [ `AVIS`, `IMPORTANT`, tab ]
		
		, [`sub`, `total`]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( ignore_majoration_prix_line, [ 
%=======================================================================

	  generic_item( [ dummy, d, `q10`, tab ] )
	  
	, q01( generic_item( [ some_code, s1, tab ] ) )
	
	, or( [ `Majoration`, `mojoration`
	
		, `TRANSPORT`

		, [ `LIV`, `-`, `DRC` ]
		
	] )
	
	, q0n(anything), tab
	
	, generic_item( [ net_subtotal_2, d, [ `$`, newline ] ] )
	
	, check( net_subtotal_2 = Net )
	
	, gross_subtotal_2( Net )

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [ 
%=======================================================================

	or( [ line_with_item_52
	
			, line_with_item_53
			
			, line_with_hash_in_descr_rule
			
			, line_with_item_at_end_of_descr_rule
			
			, line_with_missing_item 
			
		] )

] ).

%=======================================================================
i_rule_cut( line_with_hash_in_descr_rule, [ 
%=======================================================================

	  trace( [ `hash item` ] )
	  
	, read_ahead( [ q01( [ peek_fails( or( [ line_end_line, line_order_line ] ) ), line ] ), description_with_hash ] )
	  
	, line_order_line
	
	, trace( [ `hash item end` ] )

] ).

%=======================================================================
i_rule_cut( line_with_item_at_end_of_descr_rule, [ 
%=======================================================================

	  trace( [ `end of descr item` ] )
	   
	, read_ahead( or( [ single_line_descr_with_code_at_end

								, [ line, peek_fails( or( [ line_end_line, line_order_line ] ) ), continuation_with_code_at_end ]
								
							] )
							
				)
	  
	, line_order_line
	
	, trace( [ `end of descr item end` ] )

] ).

%=======================================================================
i_line_rule_cut( description_with_hash, [
%=======================================================================

	  q10( [ line_no(d), tab ] )
	  
	, q10( [ some_trash(s1), tab, check( some_trash(end) < -310 ) ] )
	  
	, q0n(word)
	
	, `#`, q01(word), line_item(f( [ begin, q(dec,5,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( single_line_descr_with_code_at_end, [
%=======================================================================

	  line_no(d), tab
	  
	, q0n(word)
	
	, line_item(f( [ begin, q(dec,5,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )
	
	, tab

] ).

%=======================================================================
i_line_rule_cut( continuation_with_code_at_end, [
%=======================================================================

	  q0n(word)
	
	, line_item(f( [ begin, q(dec,5,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )
	
	, newline

] ).

%=======================================================================
i_line_rule_cut( line_order_line, [
%=======================================================================
	
	  line_order_line_number_rule
	  
	, q10( some_trash_rule )

	, line_descr_rule

	, line_activite_rule

	, q10( line_livraison_rule )

	, line_quantity_rule
	
	, line_unite_rule

	, line_prix_rule

	, line_net_amount_rule

] ).

%=======================================================================
i_line_rule_cut( line_with_item_52, [
%=======================================================================

	  trace( [ `fournisseur item` ] )
	  
	, line_order_line_number_rule

	, q10( fake_hlt_item_rule )

	, line_descr_rule

	, q10( line_activite_rule )
	
	, line_fournisseur_rule

	, q10( line_livraison_rule )

	, line_quantity_rule
	
	, line_unite_rule

	, line_prix_rule

	, line_net_amount_rule
	
	, trace( [ `fournisseur item end` ] )

] ).

%=======================================================================
i_line_rule_cut( line_with_item_53, [
%=======================================================================

	  trace( [ `hlt item` ] )
	  
	, line_order_line_number_rule

	, line_other_hlt_item_rule

	, line_descr_rule
	
	, or( [ [ line_activite_rule

			, q10( line_livraison_rule )
			
		]
		
		, [ q10( line_activite_rule ), line_livraison_rule ]
		
	] )

	, line_quantity_rule

	, line_unite_rule

	, line_prix_rule

	, line_net_amount_rule
	
	, trace( [ `hlt item end` ] )

] ).

%=======================================================================
i_line_rule_cut( line_with_missing_item, [
%=======================================================================

	  trace( [ `missing item` ] )
	  
	, line_order_line_number_rule

	, line_item(`MISSING`)

	, line_descr_rule
	
	, or( [ [ line_activite_rule

			, q10( line_livraison_rule )
			
		]
		
		, [ q10( line_activite_rule ), line_livraison_rule ]
		
	] )

	, line_quantity_rule

	, line_unite_rule

	, line_prix_rule

	, line_net_amount_rule
	
	, trace( [ `missing item end`] )

] ).


%=======================================================================
i_line_rule_cut( line_continuation_line, [ 
%=======================================================================

	append(line_descr(s1), ` `, ``), newline

	, trace([`line description`, line_descr])

] ).

%=======================================================================
i_rule_cut( some_trash_rule, [ 
%=======================================================================

	  some_trash(s1), tab, check( some_trash(end) < -310 )

	, trace([`some trash`, some_trash])

] ).

%=======================================================================
i_rule_cut( line_order_line_number_rule, [ 
%=======================================================================

	  line_order_line_number(d), q10( tab )

	, trace([`line no`, line_order_line_number])

] ).

%=======================================================================
i_rule( line_descr_rule, [ 
%=======================================================================

	  generic_item_cut( [ line_descr, s
		, [	  
			check( line_descr(start) > -320 )
		
			, check( line_descr(end) < -33 )

			, q10( tab )
		  	
		] 
	] )
	
	, q01( [ dummy_x(s)
		
		, check( dummy_x(end) < -33 )
		
		, check( dummy_x = Dum )
		
		, append( line_descr(Dum), ` `, `` )
		
		, q10( tab )

	] )	

] ).

%=======================================================================
i_rule( line_activite_rule, [ 
%=======================================================================

	  activite(d), q10( tab )

	, check( activite(start) > -45 )
	
	, check( activite(end) < 15 )

	, trace( [`activite found`, activite] )

] ).

%=======================================================================
i_rule_cut( line_livraison_rule, [ 
%=======================================================================

	  generic_item( [ livraison, date, tab ] )

] ).

%=======================================================================
i_rule_cut( line_quantity_rule, [ 
%=======================================================================

	  line_quantity(d), tab

	, trace( [ `line quantity`, line_quantity ] )

] ).

%=======================================================================
i_rule_cut( line_unite_rule, [ 
%=======================================================================

	  unite(w), q10( tab )

	, trace( [ `unite found`, unite ] )

] ).

%=======================================================================
i_rule_cut( line_prix_rule, [ 
%=======================================================================

	  set( regexp_cross_word_boundaries )
	  
	, q10( [ `$`, set( at_front ) ] )

	, prix(d)

	, clear( regexp_cross_word_boundaries )

	, or( [ `$`
	
		, test( at_front )
		
	] )
	
	, q10( tab )

	, trace( [ `prix found` ] )

] ).

%=======================================================================
i_rule_cut( line_net_amount_rule, [ 
%=======================================================================

	  set( regexp_cross_word_boundaries )

	, generic_item_cut( [ line_net_amount, d, [ or( [ `$`, test( at_front ) ] ), newline ] ] )

	, clear( regexp_cross_word_boundaries )

] ).

%=======================================================================
i_rule_cut( line_hlt_item_rule, [ 
%=======================================================================

	  q10( [ `hlt`, `-` ] )
	  
	, line_item(f( [ begin, q(dec,5,10 ), end ] ) ), tab

	, check(line_item(end) < -320 )

	, trace([`line item`, line_item])

] ).

%=======================================================================
i_rule_cut( line_other_hlt_item_rule, [ 
%=======================================================================

	  q10( [ `hlt`, `-` ] )
	  
	, line_item(s1), tab
	  
	, check(line_item(end) < -320 )

	, trace([`line item`, line_item])

] ).

%=======================================================================
i_rule_cut( fake_hlt_item_rule, [ 
%=======================================================================

	  q10( [ `hlt`, `-` ] )
	  
	, line_item_x(s), tab

	, check(line_item_x(end) < -320 )

	, trace([`fake line item`, line_item_x])

] ).

%=======================================================================
i_rule_cut( line_fournisseur_rule, [ 
%=======================================================================

	  q10( [ `HILTI` ] ), line_item(f( [ begin, q(dec,5,10), end ] ) ), tab

	, trace([`line item`, line_item ])

] ).



%=======================================================================
%  State lookup
%-----------------------------------------------------------------------

i_user_check( ca_state, CODE, STATE )
:-
	string_to_upper(STATE, SU)
	, ca_state_lookup( CODE, SU)
.


ca_state_lookup( `AB`, `ALBERTA`).
ca_state_lookup( `BC`, `COLOMBIE-BRITANNIQUE`).
ca_state_lookup( `MB`, `MANITOBA`).
ca_state_lookup( `NB`, `NOUVEAU-BRUNSWICK`).
ca_state_lookup( `NL`, `TERRE-NEUVE-ET-LABRADOR`).
ca_state_lookup( `NS`, `NOUVELLE-ÉCOSSE`).
ca_state_lookup( `NT`, `TERRITOIRES DU NORD-OUEST`).
ca_state_lookup( `NU`, `NUNAVUT`).
ca_state_lookup( `ON`, `ONTARIO`).
ca_state_lookup( `PE`, `ÎLE-DU-PRINCE-ÉDOUARD`).
ca_state_lookup( `QC`, `QUÉBEC`).
ca_state_lookup( `SK`, `SASKATCHEWAN`).
ca_state_lookup( `YT`, `YUKON`).

ca_state_lookup( `QC`, `QUEBEC`).
ca_state_lookup( `PE`, `ILE-DU-PRINCE-EDOUARD`).
ca_state_lookup( `NS`, `NOUVELLE-ECOSSE`).



%=======================================================================
%  Street lookup
%-----------------------------------------------------------------------

i_user_check( translec_street, STREET, CITY, STATE_CODE, POST_CODE)
:-
	string_to_upper(STREET, SU)
	, translec_street_lookup( SU, CITY, STATE_CODE, POST_CODE)
.


translec_street_lookup( `2025 BOUL. FORTIN LAVAL`, `Laval`, `QC`, `H7S 1P4`).
translec_street_lookup( `1406 ROUTE 185 SUD`, `Degelis`, `QC`, `G5T 1P8`).
translec_street_lookup( `361 RUE LORRAINE`, `Trois-Riviere`, `QC`, `G8W 1G4`).
translec_street_lookup( `RTE DE LA SCIERIE DES OUTARDES 6KM DE LA 138`, `BAIE COMEAU`, `QC`, `G5C 1C5`).
translec_street_lookup( `5000 BLV. DES MILLES ILES`, `Laval`, `QC`, `H7A 4B4`).
translec_street_lookup( `174 CHEMIN LAGACÉ`, `St-André De Restigouche`, `QC`, `G0J 2G0`).
translec_street_lookup( `10 CHEMIN DES RÉSIDENCES`, `Radisson`, `QC`, `J0Y 2X0`).
translec_street_lookup( `10 chemin des résidences`, `Radisson`, `QC`, `J0Y 2X0`).
translec_street_lookup( `1450, MARIE-VICTORIN`, `ST-BRUNO`, `QC`, `J3V 6B8`).
translec_street_lookup( `174 CHEMIN LAGACE`, `St-André De Restigouche`, `QC`, `G0J 2G0`).
translec_street_lookup( `8 RUE ST-FIDELE LA MALBAIE`, `La Malbaie`, `QC`, `G5A 2K4`).
translec_street_lookup( `800, 5IÈME ET 6IÈME RANG, RR1`, `Sainte-Irène-de-Matapédia`, `QC`, `G0J 2P0`).
translec_street_lookup( `450 BOUL. LUCERNE`, `Gatineau`, `QC`, `J9A 1H1` ).
translec_street_lookup( `615, CHEMIN DU FLEUVE`, `LES CÈDRES`, `QC`, `J7T 1L3` ).
translec_street_lookup( `1406 ROUTE 185 SUD`, `Degelis`, `QC`, `G5T 1P8` ).
translec_street_lookup( `7, RUE DU CAMP`, `Fermont`, `QC`, `G0G 1J0` ).
translec_street_lookup( `2695 RUE ST-LOUIS`, `Gatineau`, `QC`, `J8V 0V7` ).

%translec_street_lookup( `5255 ROUTE 138 OUEST`, `Godalming`, `UK`, `GU7 3EB`).


i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `TRANSELEC COMMON INC` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `CONST ENERGY RENOUVELABLE S E N C` ), _, _, _, _) 
:- grammar_set( alternate_name ), result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).
i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `TRANSELEC COMMON INC` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).
