
i_version( orders05_idoc_xml_output, `12 August 2015` ).

i_output_rules_file(`output orders05_idoc_general_xml.pro`).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		21st - February
%				-	Added AUGRU line in E1EDK01 segment
%
%		13th May
%				-	Added ORTO2 segment - mapped with the user field delivery_district
%
%		4th July
%				-	Added support for bespoke e1edp19 segments
%					-	Use of bespoke_e1edp19_segment( `qualf value`, `variable to populate` )
%
%		7th July
%				-	Bug with new segment
%					-	If the segment was called there was no way to ignore it if the 
%						variable wasn't available for the current line resulting in an EEK error
%				-	Fixed by introducing a check on the existence of the variable prior to the writing of the line
%
%		14th July
%				-	Introduction of new segment
%					-	E1EDKA1 - PARVW - RE
%					-	Use of variables that will have to be named as user fields
%						-	suppliers_code_for_bill_to
%						-	buyers_code_for_bill_to
%				-	Change to how the email addresses are displayed
%					-	Changed from TELX1 to SMTP_ADDR
%					-	Segment should disappear without values
%		20th August
%				-	Introduction of two new segments`
%					-	E1EDKA1 - PARVW - AP
%						-	PARTN - buyer_location (needs user field)
%					-	E1EDKA1 - PARVW - ZV
%						-	PARTN - delivery_from_location
%
%		12th November
%				-	Ability to create custom E1EDK02 segments
%					-	i_op_param custom_e1edk02_segments needs to be set to `true`
%					-	custom_e1edk02_segment( `Qualf Value`, `Variable` ), needs to be set
%						-	If the variable doesn't exist the segment won't be created
%-------------------------------------------------------------------------------
%	2015
%-------------------------------------------------------------------------------
%		5th February
%				-	Ability to create custom E1EDK14 segments
%					-	Logic stolen from E1EDK02
%
%		6th February
%				-	Ability to create custom E1EDKA1 segments
%					-	Located in the general rules
%					-	Requires custom_e1edka1_segment( PARVW, Segment, Value ) and one of the values to be present
%					-	Can take both variables and strings if the value is fixed
%				-	Incorrect value for the E1EDK14 segment, renamed
%
%		9th February
%				-	Small Bug (Fixed)
%					-	If only a string value then section wouldn't create
%
%		25th February
%				-	Added E1EDKT1 TDFORMAT Segment population
%					-	e1edkt1_tdformat_value( Segment, Value )
%					-	RESTRICTION
%						-	TDFORMAT will be populated on all lines of the segment and must remain the same
%						-	Complications will arise if this needs to be adjusted midflow
%					-	Tweak to a stored name to prevent conflicts
%
%		2nd March
%				-	Long standing bug with e1edpt2 segments and the orders05_idoc_e1edpt2_max
%					and orders05_idoc_e1edpt2_delimiters predicates
%						-	Find and replace had stripped the names. Replaced
%		14th May
%				-	Allowed TD Format population at line level
%
%		16th June
%				-	Allowed a modifier for the custom_e1edk02_segment using custom_e1edk02_segment_modifier
%				-	This addition was made for ease - initial call was created, modifier will be rare
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_output( Checksum, VAT_totals, Version )
%-------------------------------------------------------------------------------
:- d1( write_output___( Checksum, VAT_totals, Version ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_output___( Checksum, VAT_totals, Version )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `ZORDERS05EXT` ),
	
		write_start_element( `IDOC` ),
	
			write_attribute_string( `BEGIN`, `1` ),
		
			write_edi_dc40,
		
			write_e1edk01,
		
			write_e1edk14( `008`, agent_code_3 ),
		
			write_e1edk14( `007`, agent_code_2 ),
		
			write_e1edk14( `006`, agent_code_1 ),
			
			write_custom_e1edk14_segments,
		
			write_e1edk03,

			write_e1edk17( `001`, contract_order_reference, delivery_state ),
		
			write_e1edk17( `002`, ``, buyers_code_for_location ),
		
			write_e1edka1_partner,
			
			write_e1edka1_bill_to,
		
			write_e1edka1_delivery,
			
			write_custom_e1edka1_segments,
		
			( qq_op_param( xerox_idoc_xml_extensions, _ )
			
					-> true
					
					;	write_e1edka1_buyer_contact,
						write_e1edka1_delivery_contact
			),
		
			write_e1edk02,
			
			( qq_op_param( custom_e1edk02_segments, `true` )
				->	custom_e1edk02_segment( _, Var ),
					( result( _, invoice, Var, _ )
						-> write_custom_e1edk02_segments
						
						;	true
					)
				;	true
			),
		
			( qq_op_param( xerox_idoc_xml_extensions, _ )
			
				-> write_xerox_e1edkt1_zcom
				
				;	write_all_e1edkt1
			),

			write_lines( write_line ),
	
		write_end_element,
	
	write_end_element
.	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_edi_dc40
%-------------------------------------------------------------------------------
:- d1( write_edi_dc40___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_edi_dc40___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `EDI_DC40` ),
	
		write_element_string( `TABNAM`, `EDI_DC40` ),
		
		write_element_string( `DIRECT`, `2` ),
		
		write_element_string( `IDOCTYP`, `ORDERS05` ),
		
		write_element_string( `CIMTYP`, `ZORDERS05EXT` ),
		
		write_element_string( `MESTYP`, `ORDERS` ),
		
		write_variable_as_tag( invoice, agent_name, `SNDPOR` ),
		
		write_variable_as_tag( invoice, buyer_party, `SNDPRT` ),
		
		write_variable_as_tag( invoice, buyer_registration_number, `SNDPRN` ),
		
		write_variable_as_tag( invoice, supplier_party, `RCVPRT` ),
		
		write_variable_as_tag( invoice, supplier_registration_number, `RCVPRN` ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edk01
%-------------------------------------------------------------------------------
:- d1( write_e1edk01___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edk01___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDK01` ),
	
		( qq_op_param( xerox_idoc_xml_extensions, _ ) -> true ; write_element_string( `ACTION`, `000` ) ),
		
		write_variable_as_tag( invoice, order_number, `BELNR` ),
		
		write_variable_as_tag( invoice, type_of_supply, `VSART` ),
		
		write_variable_as_tag( invoice, cost_centre, `VSART_BEZ` ),
			
		write_variable_as_tag( none, none, `AUGRU` ),
			
		write_variable_as_tag( invoice, invoice_type, `LIFSK` ),
		
		write_variable_as_tag( none, none, `AUTLF` ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edk14( QUALF, ORGID )
%-------------------------------------------------------------------------------
:- d1( write_e1edk14___( QUALF, ORGID ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edk14___( QUALF, ORGID )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDK14` ),
	
		write_variable_as_tag( invoice, QUALF, `QUALF` ),
		
		write_variable_as_tag( invoice, ORGID, `ORGID` ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edk17( QUALF, LKOND_var, LKTEXT_var )
%-------------------------------------------------------------------------------
:- d1( write_e1edk17___( QUALF, LKOND_var, LKTEXT_var ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%===============================================================================
write_e1edk17___( QUALF, LKOND_var, LKTEXT_var )
%-------------------------------------------------------------------------------
:- not( result( _, invoice, buyers_code_for_location, _ ) ).
%===============================================================================

%===============================================================================
write_e1edk17___( QUALF, LKOND_var, LKTEXT_var )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDK17` ),
	
		write_element_string( `QUALF`, QUALF ),
		
		write_variable_as_tag( invoice, LKOND_var, `LKOND` ),
		
		write_variable_as_tag( invoice, LKTEXT_var, `LKTEXT` ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edk02
%-------------------------------------------------------------------------------
:- d1( write_e1edk02___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edk02___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDK02` ),
	
		write_element_string( `QUALF`, `001` ),
		
		write_variable_as_tag( invoice, order_number, `BELNR` ),
		
		(	result( _, invoice, date, DATE )
		
				->	(	i_info_dump
				
							->	DATE_STRING = DATE
						
							;	string_date_without_hyphens( DATE_STRING, DATE )
					),
				
					write_element_string( `DATUM`, DATE_STRING )
					
				;	true
		),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_custom_e1edk02_segments
%-------------------------------------------------------------------------------
:- d1( write_custom_e1edk02_segments___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_custom_e1edk02_segments___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( custom_e1edk02_segment( Qualf, Var ),
		trace( [ `Writing`, Qualf, `with`, Var ] ),
		result( _, invoice, Var, _ ),
	
		write_custom_e1edk02_segment( Qualf, Var ),
		
		fail
		
		;	true
		
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_custom_e1edk02_segment( Qualf, Var )
%-------------------------------------------------------------------------------
:- d1( write_custom_e1edk02_segment___( Qualf, Var ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_custom_e1edk02_segment___( Qualf, Var )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDK02` ),
	
		write_element_string( `QUALF`, Qualf ),		
		write_variable_as_tag( invoice, Var, `BELNR` ),
		
		( not( custom_e1edk02_segment_modifier( Qualf, Var, no_date ) ),
			result( _, invoice, date, DATE )		
			->	( i_info_dump
					->	DATE_STRING = DATE
				
					;	string_date_without_hyphens( DATE_STRING, DATE )
				),
				write_element_string( `DATUM`, DATE_STRING )
		
			;	true
		),		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_custom_e1edk14_segments
%-------------------------------------------------------------------------------
:- d1( write_custom_e1edk14_segments___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_custom_e1edk14_segments___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( custom_e1edk14_segment( Qualf, Var ),
		result( _, invoice, Var, _ ),
	
		write_custom_e1edk14_segment( Qualf, Var ),
		
		fail
		
		;	true
		
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_custom_e1edk14_segment( Qualf, Var )
%-------------------------------------------------------------------------------
:- d1( write_custom_e1edk14_segment___( Qualf, Var ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_custom_e1edk14_segment___( Qualf, Var )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDK14` ),
	
		write_element_string( `QUALF`, Qualf ),		
		write_variable_as_tag( invoice, Var, `ORGID` ),
	
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edk03
%-------------------------------------------------------------------------------
:- d1( write_e1edk03___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edk03___
%-------------------------------------------------------------------------------
:-
%===============================================================================

		
	(	result( _, invoice, processed_delivery_date, DATE )
		
			->	(	i_info_dump
				
						->	DATE_STRING = DATE
						
						;	string_date_without_hyphens( DATE_STRING, DATE )
				),
			
				write_start_segment_1_element( `E1EDK03` ),
	
					write_element_string( `IDDAT`, `002` ),

					write_element_string( `DATUM`, DATE_STRING ),
					
				write_end_element

			;	true
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_all_e1edkt1
%-------------------------------------------------------------------------------
:- d1( write_all_e1edkt1___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
e1edkt1( `0001`, customer_comments ).		
%===============================================================================
e1edkt1( `0012`, shipping_instructions ).
%===============================================================================
e1edkt1( TDID, Var ) :- i_orders05_idocs_e1edkt1( TDID, Var ).
%===============================================================================

%===============================================================================
write_all_e1edkt1___
%-------------------------------------------------------------------------------
:- 
%===============================================================================

	e1edkt1( TDID, Var ), %this repeats
	
	write_e1edkt1( TDID, Var ),
	
	fail
	
	;
	
	true
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_e1edkt1( TDID, TDLINE_var )
%-------------------------------------------------------------------------------
:- d1( write_e1edkt1___( TDID, TDLINE_var ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_e1edkt1___( TDID, TDLINE_var )
%-------------------------------------------------------------------------------
:- not( q_available_value( invoice, TDLINE_var, `TDLINE`, false, _ ) ).
%===============================================================================

%===============================================================================
write_e1edkt1___( TDID, TDLINE_var )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDKT1` ),
	
		write_element_string( `TDID`, TDID ),
		
		sys_assertz( i_user_data( current_e1edkt1( TDID ) ) ),

		q_available_value( invoice, TDLINE_var, `TDLINE`, false, Value_out ),
		
		write_multi_segment_with_max_and_delimiter( Value_out, orders05_idoc_e1edkt2_max, orders05_idoc_e1edkt2_delimiters, `E1EDKT2`, `TDLINE` ),
		
		sys_retractall( i_user_data( current_e1edkt1( TDID ) ) ),
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_xerox_e1edkt1_zcom
%-------------------------------------------------------------------------------
:- d1( write_xerox_e1edkt1_zcom___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_xerox_e1edkt1_zcom___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	not( result( _, invoice, delivery_contact, _ ) ),
	
	not( result( _, invoice, delivery_ddi, _ ) ),
	
	not( result( _, invoice, delivery_fax, _ ) ),
	
	not( result( _, invoice, delivery_email, _ ) )	
.

%===============================================================================
write_xerox_e1edkt1_zcom___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( result( _, invoice, delivery_email, DE ) -> L1 = [ DC ] ; L1 = [] ),
	
	( result( _, invoice, delivery_fax, DF ) -> L2 = [ DF | L1 ] ; L2 = L1 ),
	
	( result( _, invoice, delivery_ddi, DD ) -> L3 = [ DD | L2 ] ; L3 = L2 ), 
	
	( result( _, invoice, delivery_contact, DC ) -> L4 = [ DC | L3 ] ; L4 = L3 ),
	
	wordcat( L4, TDLINE ),
	
	write_start_segment_1_element( `E1EDKT1` ),
	
		write_variable_as_tag( invoice, buyer_organisation, `TDID` ),
			
		write_start_segment_1_element( `E1EDKT2` ),
	
			write_variable_as_tag( invoice, TDLINE, `TDLINE` ),
			
			write_element_string( `TDFORMAT`, `*` ),
			
		write_end_element,
		
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_line( LID )
%-------------------------------------------------------------------------------
:- d1( write_line___( LID ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_line___( LID )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `E1EDP01` ),
	
		(	result( _, LID, line_order_line_number, _ )
		
				->	write_variable_as_tag( LID, line_order_line_number, `POSEX` )
				
				;	( qq_op_param( xerox_idoc_xml_extensions, _ )
				
						-> sys_string_number( LIDS, LID ),
							write_element_string( `POSEX`, LIDS )
							
						;	true
					)
		),
		
		write_variable_as_tag( LID, line_quantity, `MENGE` ),
		
		write_variable_as_tag( LID, line_quantity_uom_code, `MENEE` ),

		write_z1edp01add( LID ),
		
		write_variable_as_tag( LID, line_delivery_note_number, `WERKS` ),
		
		(	result( _, LID, processed_line_original_order_date, DATE )
		
				->	(	i_info_dump
				
							->	DATE_STRING = DATE
						
							;	string_date_without_hyphens( DATE_STRING, DATE )
					),
				
					write_start_segment_1_element( `E1EDP03` ),
		
						write_element_string( `IDDAT`, `002` ),
		
						write_element_string( `DATUM`, DATE_STRING ),	
	
					write_end_element
					
				;	true
		),

		(	result( _, LID, line_item_for_buyer, BUYER_ITEM )
		
				->	write_start_segment_1_element( `E1EDP19` ),
		
						write_element_string( `QUALF`, `001` ),
		
						write_processed_element_string( line_item_for_buyer, `IDTNR`, BUYER_ITEM ),	
	
					write_end_element
					
				;	true
		),

		(	result( _, LID, line_item, ITEM )
		
				->	write_start_segment_1_element( `E1EDP19` ),
		
						write_element_string( `QUALF`, `002` ),
		
						write_processed_element_string( line_item, `IDTNR`, ITEM ),	
	
					write_end_element
					
				;	true
		),
		
		write_additional_e1edp19_segments( LID ),

		(	result( _, LID, line_descr, DESCR )
		
				->	write_start_segment_1_element( `E1EDPT1` ),
				
						sys_assertz( i_user_data( current_e1edpt1( `Z006` ) ) ),
		
						write_element_string( `TDID`, `Z006` ),

					 	pre_process_tag_value( line_descr, DESCR, PP_DESCR ),

						write_multi_segment_with_max_and_delimiter( PP_DESCR, orders05_idoc_e1edpt2_max, orders05_idoc_e1edpt2_delimiters, `E1EDPT2`, `TDLINE` ),
						
						sys_retractall( i_user_data( current_e1edpt1( `Z006` ) ) ),
					
					write_end_element
					
				;	true
		),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_additional_e1edp19_segments( LID )
%-------------------------------------------------------------------------------
:- d1( write_additional_e1edp19_segments___( LID ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_additional_e1edp19_segments___( LID )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( bespoke_e1edp19_segment( Values ),
	
		write_bespoke_e1edp19_segment( LID, Values ),
		
		fail
		
		;	true
		
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_bespoke_e1edp19_segment( LID, [ Qualf, Variable ] )
%-------------------------------------------------------------------------------
:- d1( write_bespoke_e1edp19_segment___( LID, [ Qualf, Variable ] ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_bespoke_e1edp19_segment___( LID, [ Qualf, Variable ] )
%-------------------------------------------------------------------------------
:- not( result( _, LID, Variable, _ ) ).
%===============================================================================

%===============================================================================
write_bespoke_e1edp19_segment___( LID, [ Qualf, Variable ] )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	result( _, LID, Variable, Variable_Value ),
	
	write_start_segment_1_element( `E1EDP19` ),
	
	write_element_string( `QUALF`, Qualf ),

	write_processed_element_string( Variable, `IDTNR`, Variable_Value ),	

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_z1edp01add( LID )
%-------------------------------------------------------------------------------
:- d1( write_z1edp01add___( LID ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_z1edp01add___( LID )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	not( q_available_value( [ write_start_element( `Z1EDP01ADD` ) ], LID, none, `ZZFMCONTRACTTYPE`, false, _ ) ),

	not( q_available_value( [ write_start_element( `Z1EDP01ADD` ) ], LID, none, `ZZFMINVNR`, false, _ ) ),

	not( q_available_value( [ write_start_element( `Z1EDP01ADD` ) ], LID, none, `ZZFMORGREF`, false, _ ) ),

	not( q_available_value( [ write_start_element( `Z1EDP01ADD` ) ], LID, none, `ZZFMTHEFTINSURANCE`, false, _ ) ),

	not( q_available_value( [ write_start_element( `Z1EDP01ADD` ) ], LID, none, `ZZFMFOLLOWUP`, false, _ ) ),

	not( q_available_value( [ write_start_element( `Z1EDP01ADD` ) ], LID, none, `ZZFMPRECONTRACTNO`, false, _ ) ),

	not( q_available_value( [ write_start_element( `Z1EDP01ADD` ) ], LID, none, `ZZFMPRELDETSPOSNR`, false, _ ) )
.

%===============================================================================
write_z1edp01add___( LID )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_segment_1_element( `Z1EDP01ADD` ),

      		write_variable_as_tag( LID, none, `ZZFMCONTRACTTYPE` ),
      		write_variable_as_tag( LID, none, `ZZFMINVNR` ),
      		write_variable_as_tag( LID, none, `ZZFMORGREF` ),
      		write_variable_as_tag( LID, none, `ZZFMTHEFTINSURANCE` ),
      		write_variable_as_tag( LID, none, `ZZFMFOLLOWUP` ),
      		write_variable_as_tag( LID, none, `ZZFMPRECONTRACTNO` ),
      		write_variable_as_tag( LID, none, `ZZFMPRELDETSPOSNR` ),

	write_end_element
.
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_multi_segment_with_max_and_delimiter( Value, Max_config, Delimiters_config, Segment, Tag )
%-------------------------------------------------------------------------------
:- d1( write_multi_segment_with_max_and_delimiter___( Value,  Max_config, Delimiters_config, Segment, Tag ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_multi_segment_with_max_and_delimiter___( Value, Max_config, Delimiters_config, Segment, Tag )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	i_config_param( Delimiters_config, Delimiters ),
	
	sys_string_split( Value, Delimiters, Value_list ),
	
	( i_config_param( Max_config, Max ) -> true ; Max = 9999 ),
		
	write_multi_segment_with_max_from_list( Value_list, Max, Segment, Tag )
.
						
%===============================================================================
write_multi_segment_with_max_and_delimiter___( Value, Max_config, Delimiters_config, Segment, Tag )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( i_config_param( Max_config, Max ) -> true ; Max = 9999 ),
		
	write_multi_segment_with_max( Value, Max, Segment, Tag )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_multi_segment_with_max_from_list( Value_list, Max, Segment, Tag )
%-------------------------------------------------------------------------------
:- d1( write_multi_segment_with_max_from_list___( Value_list, Max, Segment, Tag ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_multi_segment_with_max_from_list___( [], Max, Segment, Tag ).
%===============================================================================

%===============================================================================
write_multi_segment_with_max_from_list___( [ H | T ], Max, Segment, Tag )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_multi_segment_with_max( H, Max, Segment, Tag ),
	
	!, write_multi_segment_with_max_from_list( T, Max, Segment, Tag )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_multi_segment_with_max( Value, Max, Segment, Tag )
%-------------------------------------------------------------------------------
:- d1( write_multi_segment_with_max___( Value, Max, Segment, Tag ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_multi_segment_with_max___( Value, Max, Segment, Tag )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	sys_string_length( Value, Length ),
	
	q_sys_comp( Length =< Max ),
	
	write_segment( Value, Segment, Tag )	

.

%===============================================================================
write_multi_segment_with_max___( Value, Max, Segment, Tag )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	get_next_segment( Value, Max, Next_value, Remaining_value ),

	write_segment( Next_value, Segment, Tag ),

	!, write_multi_segment_with_max( Remaining_value, Max, Segment, Tag )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_next_segment( Value, Max, Next_value, Remaining_value )
%-------------------------------------------------------------------------------
:- d1( get_next_segment___( Value, Max, Next_value, Remaining_value ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
get_next_segment___( Value, Max, FIRST, REST )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	q_sys_sub_string( Value, 1, Max, Max_V ),
	
	q_sys_sub_string( Max_V, I_SPACE, 1, ` ` ),
	
	sys_string_list( Max_V, VLIST ),
	
	sys_reverse( VLIST, VR ),
	
	sys_append( REST_R, " ", REST_R_PLUS_SPACE ),
	
	sys_append( REST_R_PLUS_SPACE, FIRST_R, VR ),
	
	sys_reverse( REST_R, REST_LIST ),
	
	sys_reverse( FIRST_R, FIRST_LIST ),
	
	sys_string_list( FIRST, FIRST_LIST ),
	
	sys_string_list( REST_PT1, REST_LIST ),
	
	sys_calculate( Next, Max + 1 ),
	
	q_sys_sub_string( Value, Next, _, REST_PT2 ),
	
	sys_strcat( REST_PT1, REST_PT2, REST ) 
.

%===============================================================================
get_next_segment___( Value, Max, Next_value, Remaining_value )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	q_sys_sub_string( Value, 1, Max, Next_value ),
	
	sys_calculate( Next, Max + 1 ),
	
	q_sys_sub_string( Value, Next, _, Remaining_value )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_segment( Value, Segment, Tag )
%-------------------------------------------------------------------------------
:- d1( write_segment___( Value, Segment, Tag ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_segment___( Value, Segment, Tag )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( q_sys_comp( Value = `` )
	
		->	true
		
		;	write_start_segment_1_element( Segment ),
		
				write_element_string( Tag, Value ),
				
				( Segment = `E1EDKT2`,
					i_user_data( current_e1edkt1( TDID ) ),
					e1edkt1_tdformat_value( TDID, TDFORMATValue )
						->	write_element_string( `TDFORMAT`, TDFORMATValue )
						
						;	true
				),
			
				( Segment = `E1EDPT2`,
					i_user_data( current_e1edpt1( TDID ) ),
					e1edpt2_tdformat_value( TDID, TDFORMATValue )
						->	write_element_string( `TDFORMAT`, TDFORMATValue )
						
						;	true
				),
		
			write_end_element
	)
.

