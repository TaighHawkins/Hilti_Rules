%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - QUOTES AUTO PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( quote_auto_process, `29 July 2015` ).

i_date_format( _ ).

%=======================================================================
%	Quotation Number
%-----------------------------------------------------------------------
i_op_param( custom_e1edk02_segments, _, _, _, `true` ).
i_user_field( invoice, quotation_number, `Quotation Number` ).
custom_e1edk02_segment( `004`, quotation_number ).
%=======================================================================

%=======================================================================
%	Forced Defects
%-----------------------------------------------------------------------
defect( _, missing( order_number ) ).
defect( _, missing( quotation_number ) ).
%=======================================================================

%=======================================================================
%	Email Handling
%-----------------------------------------------------------------------
i_op_param( addr( _ ), From, _, _, From )
:- unknown_destination, q_hilti_address( From ), trace( [ `Returning to Hilti Address` ] ).
%-----------------------------------------------------------------------
q_hilti_address( Addr ) :- q_regexp_match( `.*hilti.com`, Addr, _ ).
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
i_op_param( addr( _ ), _, _, _, `taigh.hawkins@adaptris-ecx.com` )
:- unknown_destination.
i_op_param( o_mail_subject, _, _, _, `Unknown Email Address - Quotation NOT converted` ):- unknown_destination.
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
unknown_destination
%-----------------------------------------------------------------------
:-
	( grammar_set( unknown_id ); data( unknown_id, `true` ) ),
	i_mail( attachment, Attachment ),
	string_to_lower( Attachment, Attachment_L ),
	q_sys_sub_string( Attachment_L, _, _, `body.htm` ),
	trace( [ `Body NOT from a recognised sender` ] )
.
%-----------------------------------------------------------------------
%=======================================================================

%=======================================================================
%	American AUGRU segment
%-----------------------------------------------------------------------
i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ):- grammar_set( n_america ).
%=======================================================================

%=======================================================================
%	Used to identify particular PDFs that may be of interest
%=======================================================================
%=======================================================================

i_page_split_rule_list( [
%=======================================================================


	  set( chain, `junk` )
	  
	, select_buyer

] )
:-	i_mail( attachment, Attachment ),
	string_to_lower( Attachment, Attachment_L ),
	not( q_sys_sub_string( Attachment_L, _, _, `body.htm` ) )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SELECT BUYER

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( select_buyer, [ 
%=======================================================================

	q0n(line), check_text_identification_line
	
] ).

%=======================================================================
i_line_rule( check_text_identification_line, [ or( [ 
%=======================================================================

	[ check_text( `interserveengineeringservices` ), set(chain, `csv_ies`), trace([`INTERSERVE ENGINEERING SERVICES ...`])
		, set_priority_attachment
	]
	
	, [ check_text( `DEPARTMENTOFWATERANDPOWER` ), set( chain, `us dwp` ), trace( [ `DEPARTMENT OF WATER AND POWER ...` ] )
		, prevent_attachment_delay
	]

] ) ] ).

%=======================================================================
%	Special Attachment Handling
%=======================================================================
i_rule( set_priority_attachment, [ check( set_imail_data( `body`, `do_not_process` ) ) ] ).
%-----------------------------------------------------------------------
i_rule( prevent_attachment_delay, [ check( set_imail_data( `pdf`, `no_delay` ) ) ] ).
%=======================================================================

%=======================================================================
%	Rules for Body Processing - only runs on body.htm
%=======================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, check_final_line_number
	
	, check_from_address
	
	, check_origin_identifier

	, get_quotation_number_safe
	
	, get_quotation_number_unsafe
	
	, get_order_number

	, get_regional_variables

	, check_if_quotation_succeeded
	
	, check_if_body_processed

] )
:-	not( q_imail_data( not_self, `body`, `do_not_process` ) ),
	i_mail( attachment, Attachment ),
	string_to_lower( Attachment, Attachment_L ),
	q_sys_sub_string( Attachment_L, _, _, `body.htm` )
.

%=======================================================================
%	If the attachment is for Interserve it will dispose of the body
%=======================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  set( chain, `junk` )
	  
	, trace( [ `Junking body - priority attachment` ] )

] )
:-	q_imail_data( not_self, `body`, `do_not_process` ),
	i_mail( attachment, Attachment ),
	string_to_lower( Attachment, Attachment_L ),
	q_sys_sub_string( Attachment_L, _, _, `body.htm` )
.

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

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Quote Auto Response` )
	
] ).

%=======================================================================
i_rule( get_regional_variables, [ 
%=======================================================================

	buyer_registration_number( BuyerReg )
	, agent_code_3( Agent3 )
	
	, or( [ 

		[ test(test_flag)
			, suppliers_code_for_buyer( Test )   
			, delivery_note_number( Test )   
		]   

		, [ suppliers_code_for_buyer( Prod )
			, delivery_note_number( Prod ) 
		]

	] ) 
	
] ):- regional_values( BuyerReg, Agent3, Test, Prod, Language ), grammar_set( Language ).

%=======================================================================
%	Table for all Regional Values
%=======================================================================
% regional_values( SNDPRN, ORGID, TEST AP, PROD AP, LANGUAGE ).
%=======================================================================
regional_values( `IT-QUOTES`, `7500`, `10592785`, `10088718`, italian ).
%-----------------------------------------------------------------------
regional_values( `GB-QUOTES`, `4400`, `10581786`, `12345676`, english ).
%-----------------------------------------------------------------------
regional_values( `IE-QUOTES`, `4600`, `16503574`, `16503574`, irish ).
%-----------------------------------------------------------------------
regional_values( `US-QUOTES`, `6000`, `11232646`, `10769760`, n_america ).
%-----------------------------------------------------------------------
regional_values( `FR-ADAPTRI`, `0900`, `10558391`, `12154529`, french ).
%-----------------------------------------------------------------------
regional_values( `AU-QUOTES`, `2500`, `10493821`, `13982187`, australian ).
%-----------------------------------------------------------------------
regional_values( `SA-QUOTES`, `9200`, `11184402`, `21395014`, saudi_arabia ).
%-----------------------------------------------------------------------
regional_values( `ZA-QUOTES`, `9150`, `11198515`, `15458924`, south_africa ).
%-----------------------------------------------------------------------
regional_values( `HK-QUOTES`, `2300`, `11202429`, `16112348`, hong_kong ).
%-----------------------------------------------------------------------
regional_values( `AE-QUOTES`, `9250`, `11186154`, `21291216`, united_arab_emirates ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FROM ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	From address is the preferred method of identification
%	New method uses the i_user_check
%=======================================================================
i_rule( check_from_address, [ 
%=======================================================================

	or( [ 
	
		[ or( [
				[ check( i_user_check( identify_sender_from_email_address, FromL, Flag, Trace ) )
					, trace( [ Trace, Flag ] )
					, set( Flag )
				]
		
				, [ check(

						q_sys_member( FromL
							, [ `acquisti@hilti.com`, `marco.moretti@hilti.com`, `luigifrancesco.pazetti@hilti.com`, `luciana.balini@hilti.com`
								, `hilti.offerta@hilti.com`
							] 
						) 
					)
			
					, set( italian ), trace( [ `Italian Quotation` ] )
				]
				
				, [ check( q_sys_member( FromL, [ `us-sales@hilti.com` ] ) )
					, set( n_america )
					, trace( [ `US Quotation` ] )
				]
				
				, [ check( q_sys_member( FromL, [ `gbsales@hilti.com`, `gbteamsales@hilti.com` ] ) )
					, set( english )
					, trace( [ `GB QUOTE` ] )
				]
				
				, [ check( q_sys_member( FromL, [ `irlsales@hilti.com` ] ) )
					, set( irish )
					, trace( [ `IRISH QUOTE` ] )
				]
				, [ check( q_sys_member( FromL, [ `hilti-france@hilti.com`, `roger.zeller@hilti.com`, `antoine.salaun@hilti.com` ] ) )
					, set( french )
					, trace( [ `FRENCH QUOTE` ] )
				]
				
			] )
			
			, set( used_from )
		]
		
		, [ set( unknown_id ), trace( [ `Unrecognised Email Sender` ] ) ]
		
	] )

] ):- i_mail( from, From ), string_to_lower( From, FromL ).

i_user_check( identify_sender_from_email_address, From, Flag, Trace )
:-
	trace( `In identification` ),
	sender_identity_table( Senders, Flag, Trace ),
	trace( [ `Senders`, Senders ] ),
	q_sys_member( From, Senders )
.

%=======================================================================
%	Table for all Recognised Email Addresses
%=======================================================================
% sender_identity_table( [ List of email addresses ], Region, Trace Message ).
%=======================================================================
sender_identity_table( [ `acquisti@hilti.com`, `marco.moretti@hilti.com`, `luigifrancesco.pazetti@hilti.com`, `luciana.balini@hilti.com`, `hilti.offerta@hilti.com` ], italian, `Italian Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `us-sales@hilti.com` ], n_america, `US Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `gbsales@hilti.com`, `gbteamsales@hilti.com` ], english, `GB Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `irlsales@hilti.com` ], irish, `Irish Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `hilti-france@hilti.com`, `roger.zeller@hilti.com`, `antoine.salaun@hilti.com` ], french, `French Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `serviceaustralia@hilti.com`, `james.henry@hilti.com`, `aub2b@hilti.com` ], australian, `Australian Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `sa.customerservice@hilti.com` ], saudi_arabia, `Saudi Arabia Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `customercare.za@hilti.com` ], south_africa, `South Africa Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `hksales@hilti.com` ], hong_kong, `Hong Kong Quotation` ).
%-----------------------------------------------------------------------
sender_identity_table( [ `ae.contactus@hilti.com` ], united_arab_emirates, `UAE Quotation` ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORIGIN (OLD )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	This method uses the signature, primarily for testing purposes
%=======================================================================
i_rule( check_origin_identifier, [ 
%=======================================================================

	peek_fails( test( used_from ) )
	
	, q0n(line), check_origin_line
	
] ).

%=======================================================================
i_line_rule( check_origin_line, [ 
%=======================================================================

	Search, set( Flag )
	
	, trace( [ `Origin:`, Flag ] )
	
	, clear( unknown_id )
	, trace( [ `Determined from Signature` ] )
	
] ):- quote_origin_identifier( Search, Flag ).


%=======================================================================
%	Table for Signature Searches
%=======================================================================
% quote_origin_identifier( [ The Search String as a list ], Region ).
%=======================================================================
quote_origin_identifier( [ `Hilti`, `(`, `Fastening`, `Systems`, `)`, `Limited` ], irish ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Hilti`, `(`, `Gt`, `.`, `Britain`, `)`, `Ltd` ], english ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Hilti`, `(`, `GB`, `)`, `Ltd` ], english ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Hilti`, `North`, `America` ], n_america ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Hilti`, `France` ], french ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Email`, `:`, `sa`, `.`, `customerservice`, `@`, `hilti`, `.`, `com` ], saudi_arabia ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Hilti`, `South`, `Africa` ], south_africa ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Hilti`, `(`, `Hong`, `Kong` ], hong_kong ).
%-----------------------------------------------------------------------
quote_origin_identifier( [ `Hilti`, `Emirates` ], united_arab_emirates ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FINAL LINE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Became necessary when single line entries were sent - shouldn't really exist
%=======================================================================
i_rule( check_final_line_number, [ 
%=======================================================================

	  set( morethanone )
	, trace( [ `More than one line` ] )

] ):- raw_pdf_page_info( _, _, LineCount, _, _, _, _ ), LineCount > 1 .


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Expectation
%		Clean up of Subject will be required
%
%	Reality
%		Clean up of subject - multiple languages
%		Allow for variations
%			-	Different cases
%			-	'Go Ahead' to move throughout the subject
%			-	Go ahead and a separator to be joined
%			-	Maintaining order number intergrity
%=======================================================================
%	English
%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================
	
	order_number( SubjectOut )
	, trace( [ `Order Number from Subject`, order_number ] )

] )
:- 
	english_subject( Flag ),
	grammar_set( Flag ),
	i_mail( subject, S ),
	string_to_lower( S, SL ),
	( q_sys_sub_string( S, Space, _, ` ` ),
		trace( start( Space ) ),
		sys_calculate( SpacePlusOne, Space + 1 ),
		trace( spaceplusone( SpacePlusOne ) ),
		q_sys_sub_string( SL, SpacePlusOne, _, Remainder ),
		trace( rem( Remainder ) ),
		not( q_sys_sub_string( SL, SpacePlusOne, 5, `ahead` ) )
			->	sys_string_split( S, ` `, SList ),
				( sys_append( _, [ First, Second | SubjectOutList ], SList ),
					trace( go_ahead( [ First, Second ] ) ),
					trace( out( SubjectOutList ) ),
					wordcat( [ First, Second ], GoAhead ),
					trace( wc( GoAhead ) )
					
					;	sys_append( _, [ First, Second, Third | SubjectOutList ], SList ),
						wordcat( [ First, Second, Third ], GoAhead )
				),
				wordcat( SubjectOutList, SubjectOut ),
				string_to_lower( GoAhead, GoAheadL ),
				strip_string2_from_string1( GoAheadL, `:-.,_;`, GoAheadStrip ),
				trace( string( GoAheadStrip ) ),
				go_ahead_check( GoAheadStrip )
				
			;	q_sys_sub_string( SL, StartGo, _, `go ahead` ),
				sys_calculate( StartOfOrder, StartGo + 9 ),
				q_sys_sub_string( S, StartOfOrder, _, SubjectOut )
			
			;	not( no_default_subject( Flag ) ),
				S = SubjectOut
	),
	SubjectOut \= ``

.

english_subject( english ).
english_subject( irish ).
english_subject( australian ).
english_subject( n_america ).
english_subject( saudi_arabia ).
english_subject( south_africa ).
english_subject( hong_kong ).
english_subject( united_arab_emirates ).

no_default_subject( australian ).
no_default_subject( united_arab_emirates ).
no_default_subject( hong_kong ).
no_default_subject( south_africa ).
no_default_subject( saudi_arabia ).

go_ahead_check( `go ahead` ).
go_ahead_check( `rego ahead` ).
go_ahead_check( `re go ahead` ).
go_ahead_check( `fwgo ahead` ).
go_ahead_check( `fw go ahead` ).


%=======================================================================
%	Australian
%=======================================================================

i_op_param( xml_transform( order_number, In ), _, _, _, Out )
:-
	grammar_set( australian ),
	strip_string2_from_string1( In, ` `, Out )
.

%=======================================================================
%	Italian
%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================
	
	order_number( SubjectOut )
	, trace( [ `Order Number from Subject`, order_number ] )


] )
:- 
	grammar_set( italian ),
	i_mail( subject, S ),
	( q_sys_sub_string( S, _, _, ` ` ),
		sys_string_split( S, ` `, SList ),
		sys_append( [ First ], SubjectOutList, SList ),


		wordcat( SubjectOutList, SubjectOut ),
		string_to_lower( First, FirstL ),
		strip_string2_from_string1( FirstL, `:`, FirstStrip ),
		trace( string( FirstStrip ) ),
		italian_email_check( FirstStrip )
	
		;	S = SubjectOut
	)
.

italian_email_check( `i` ).
italian_email_check( `fw` ).


%=======================================================================
%	French
%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================
	
	order_number( SubjectOut )
	, trace( [ `Order Number from Subject`, order_number ] )

] )
:- 
	grammar_set( french ),

	i_mail( subject, S ),
	( q_sys_sub_string( S, _, _, ` ` ),
		sys_string_split( S, ` `, SList ),
		sys_append( FirstList, SubjectOutList, SList ),


		wordcat( SubjectOutList, SubjectOut ),
		wordcat( FirstList, First ),
		string_to_lower( First, FirstL ),
		strip_string2_from_string1( FirstL, `:`, FirstStrip ),
		trace( string( FirstStrip ) ),
		french_order_check( CheckString ),
		q_sys_sub_string( FirstStrip, _, _, CheckString )
	
		;	S = SubjectOut
	)
.

french_order_check( `bon pour accord` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUOTATION NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Expectation
%		Standardised format will change - Quotation number will move
%
%	Reality
%		Quotation number relatively static
%		Multiple Languages
%
%	The 'unsafe' search from GB Hilti caused misidentification if the rules were run line by line.
%	Splitting the searches into 'Safe' and 'Unsafe' varieties has added some security - though if the IT
%	Quotation cannot be found it will find the GB version.
%	Need to find a catch
%
%	Using the email address check - acquisti is an Italian quote
%
%	Removal of 'unsafe' search due to capture of a VAT code incorrectly.
%=======================================================================
i_rule( get_quotation_number_safe, [ q0n(line), xor( [ [ test( morethanone ), check( Line = 2 ) ], check( Line = 1 ) ] ), quotation_number_safe_line( Line ) ] ).
%=======================================================================
i_line_rule( quotation_number_safe_line, [
%=======================================================================
	
	test( Language )
	
	, q0n(word), Search
	
	, generic_item( [ quotation_number, Par, q10( After ) ] )

] ):- quotation_number_safe_search( Search, After, Par, Language ).

%=======================================================================
%	Table for Quotation Number Locations
%=======================================================================
% sender_identity_table( [ List of text before ],
%	List of Text After,
%	Parameter, (Support for regexp if required)
%	Region
% ).
%=======================================================================
quotation_number_safe_search( [ `della`, `miglior`, `offerta`, `n`, q10( `.` ) ], 
	[ `a`, `Lei`, `riservata` ],
	sf,
	italian 
).
%-----------------------------------------------------------------------

quotation_number_safe_search( [ `Please`, `find`, `attached`, `our`, `quotation` ], 
	[ `as` ],
	sf,
	n_america 
).
%-----------------------------------------------------------------------

quotation_number_safe_search( [ `Please`, `find`, `attached`, `our`, `quotation` ], 
	[ `as` ],
	sf,
	english 
).
%-----------------------------------------------------------------------

quotation_number_safe_search( [ `Please`, `find`, `attached`, `our`, `quotation` ], 
	[ `as` ],
	sf,
	irish 
).
%-----------------------------------------------------------------------
quotation_number_safe_search( [ `Please`, `find`, `attached`, `our`, `quotation` ], 
	[ `as` ],
	sf,
	australian 
).
%-----------------------------------------------------------------------
quotation_number_safe_search( [ `Please`, `find`, `attached`, `our`, `quotation` ], 
	[ `as` ],
	sf,
	saudi_arabia 
).
%-----------------------------------------------------------------------
quotation_number_safe_search( [ `Please`, `find`, `attached`, `our`, `quotation` ], 
	[ `as` ],
	sf,
	hong_kong 
).
%-----------------------------------------------------------------------
quotation_number_safe_search( [ `Please`, `find`, `attached`, `our`, `quotation` ], 
	[ `as` ],
	sf,
	united_arab_emirates 
).
%-----------------------------------------------------------------------
quotation_number_safe_search( [ `your`, `records`, `.`, `Reference`, `Number`, `:` ], 
	[ `.` ],
	sf,
	south_africa 
).
%-----------------------------------------------------------------------
quotation_number_safe_search( [ `adresser`, `notre`, `proposition`, `commerciale` ], 
	[ `concemant` ],
	sf,
	french 
).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNSAFE QUOTATION NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Been disabled - should perhaps not exist
%=======================================================================
ii_rule( get_quotation_number_unsafe, [ 
%=======================================================================
	
	without( quotation_number ), peek_fails( test( italian ) )
	
	, q0n(line), xor( [ [ test( morethanone ), check( Line = 2 ) ], check( Line = 1 ) ] )
	
	, quotation_number_unsafe_line( Line ) 
	
] ).




%=======================================================================
i_line_rule( quotation_number_unsafe_line, [
%=======================================================================

	Search
	
	, generic_item( [ quotation_number, Par, After ] )

] ):- quotation_number_unsafe_search( Search, After, Par, Language ).

quotation_number_unsafe_search( [ q0n(anything) ], 
	[ peek_fails( [ `a`, `Lei`, `riservata` ] ) ],
	[ begin, q(dec("9"),1,1), q(dec,8,8), end ],
	english 
).

%=======================================================================
i_line_rule( quotation_number_unsafe_line, [
%=======================================================================

	Search
	
	, generic_item( [ quotation_number, Par, After ] )

] ):- quotation_number_unsafe_search( Search, After, Par, Language ).

quotation_number_unsafe_search( [ q0n(anything) ], 
	[ peek_fails( [ `a`, `Lei`, `riservata` ] ) ],
	[ begin, q(dec("1"),1,1), q(dec("9"),1,1), q(dec,6,8), end ],
	english 
).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUCCESS CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Simple - just success if present, failure otherwise.


%
%=======================================================================
i_rule( check_if_quotation_succeeded, [
%=======================================================================
	
	or( [ [ with( order_number )
			, with( quotation_number )
	
			, check( set_imail_data( `quotation`, `succeeded` ) )
			, force_result( `success` )
		]
		, [ trace( [ `Quotation number not found - Order not processed` ] ) ]
	] )		
] ).

%=======================================================================
i_rule( check_if_body_processed, [ check( set_imail_data( `body`, `processed` ) ) ] ).
%=======================================================================