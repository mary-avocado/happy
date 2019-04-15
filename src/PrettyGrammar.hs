module PrettyGrammar where

import Prelude hiding ((<>))
import AbsSyn

render :: Doc -> String
render = maybe "" ($ "")

ppAbsSyn :: AbsSyn -> Doc
ppAbsSyn (AbsSyn _ ds rs _) = vsep (vcat (map ppDirective ds) : map ppRule rs)

ppDirective :: Directive a -> Doc
ppDirective dir =
  case dir of
    TokenNonassoc xs -> prec "%nonassoc" xs
    TokenRight xs    -> prec "%right" xs
    TokenLeft xs     -> prec "%left" xs
    _                -> empty
  where
  prec x xs = text x <+> hsep (map text xs)

ppRule :: Rule -> Doc
ppRule (name,_,prods,_) = text name
                       $$ vcat (zipWith (<+>) starts (map ppProd prods))
  where
  starts = text "  :" : repeat (text "  |")

ppProd :: Prod -> Doc
ppProd (ts,_,_,p) = psDoc <+> precDoc
  where
  psDoc   = if null ts then text "{- empty -}" else hsep (map ppTerm ts)
  precDoc = maybe empty (\x -> text "%prec" <+> text x) p

ppTerm :: Term -> Doc
ppTerm (App x ts) = text x <> ppTuple (map ppTerm ts)

ppTuple :: [Doc] -> Doc
ppTuple [] = empty
ppTuple xs = parens (hsep (punctuate comma xs))

--------------------------------------------------------------------------------
-- Pretty printing combinator

type Doc = Maybe ShowS

empty :: Doc
empty = Nothing

punctuate :: Doc -> [Doc] -> [Doc]
punctuate _ []  = []
punctuate _ [x] = [x]
punctuate sep (x : xs) = (x <> sep) : punctuate sep xs

comma ::  Doc
comma = char ','

char :: Char -> Doc
char x = Just (showChar x)

text :: String -> Doc
text x = if null x then Nothing else Just (showString x)

(<+>) :: Doc -> Doc -> Doc
Nothing <+> y     = y
x <+> Nothing     = x
x <+> y           = x <> char ' ' <> y

(<>) :: Doc -> Doc -> Doc
Nothing <> y = y
x <> Nothing = x
Just x <> Just y = Just (x . y)

($$) :: Doc -> Doc -> Doc
Nothing $$ y = y
x $$ Nothing = x
x $$ y       = x <> char '\n' <> y

hsep :: [Doc] -> Doc
hsep = hcat . punctuate (char ' ')

vcat :: [Doc] -> Doc
vcat = foldr ($$) empty

vsep :: [Doc] -> Doc
vsep = vcat . punctuate (char '\n')

parens :: Doc -> Doc
parens x = char '(' <> x <> char ')'

hcat :: [Doc] -> Doc
hcat = foldr (<>) empty

