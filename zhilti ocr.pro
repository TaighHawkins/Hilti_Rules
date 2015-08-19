%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI OCR TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_ocr_chain, `16 October 2014` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


i_pdf_parameter( try_ocr, `yes` ).
%i_pdf_parameter( max_pages, 1 ).
i_pdf_parameter( new_line, 12 ).
i_pdf_parameter( same_line, 3).
i_pdf_parameter( tab, 10 ).
i_pdf_parameter( space, 5 ).


i_page_split_rule_list( [ set(chain,`unrecognised`), select_buyer] ).

%=======================================================================
i_rule( select_buyer, [ 
%=======================================================================

	or( [ [ q0n(line), checktext_identification_line ]

	] )
	
] ).

%=======================================================================
i_line_rule( checktext_identification_line, [
%=======================================================================

	  or( [ [ check_text(`azmeel`), set(chain, `azmeel`), trace([`AZMEEL ...`])  ]


	] )
	
] ).
