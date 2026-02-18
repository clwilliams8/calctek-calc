<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Laravel\Socialite\Facades\Socialite;

class GoogleAuthController extends Controller
{
    public function redirect(Request $request)
    {
        if ($request->query('platform') === 'mobile') {
            cookie()->queue('oauth_platform', 'mobile', 5);
        }

        return Socialite::driver('google')->redirect();
    }

    public function callback(Request $request)
    {
        $googleUser = Socialite::driver('google')->user();

        $user = User::updateOrCreate(
            ['google_id' => $googleUser->getId()],
            [
                'name' => $googleUser->getName(),
                'email' => $googleUser->getEmail(),
                'avatar' => $googleUser->getAvatar(),
            ],
        );

        $token = $user->createToken('auth-token')->plainTextToken;

        $isMobile = $request->cookie('oauth_platform') === 'mobile';

        if ($isMobile) {
            cookie()->queue(cookie()->forget('oauth_platform'));

            return redirect("calctekapp://auth/callback?token={$token}");
        }

        $frontendUrl = config('app.frontend_url');

        return redirect("{$frontendUrl}/auth/callback?token={$token}");
    }
}
